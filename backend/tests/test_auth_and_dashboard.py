import uuid
import pytest
from httpx import AsyncClient, ASGITransport
from app.main import app
from app.services.auth_service import auth_service
from app.core.database import AsyncSessionLocal


@pytest.mark.asyncio
async def test_health_and_root():
    transport = ASGITransport(app=app)
    async with AsyncClient(transport=transport, base_url="http://test") as client:
        resp = await client.get("/health")
        assert resp.status_code == 200
        assert resp.json()["status"] == "healthy"

        resp_root = await client.get("/")
        assert resp_root.status_code == 200


@pytest.mark.asyncio
async def test_full_auth_and_dashboard_flow():
    transport = ASGITransport(app=app)
    async with AsyncClient(transport=transport, base_url="http://test") as client:
        test_email = f"farmer.ramesh.{uuid.uuid4().hex[:8]}@example.com"
        test_password = "SecurePassword123!"

        # 1. Signup
        signup_payload = {
            "name": "Ramesh Patel",
            "email": test_email,
            "password": test_password,
            "phone": "+919876543211",
            "preferred_locale": "hi",
        }
        res_signup = await client.post("/v1/auth/signup", json=signup_payload)
        assert res_signup.status_code == 201, res_signup.text
        data = res_signup.json()
        assert "tokens" in data
        assert "access_token" in data
        assert "refresh_token" in data
        assert data["user"]["email"] == test_email
        assert data["user"]["name"] == "Ramesh Patel"

        access_token = data["access_token"]
        refresh_token = data["refresh_token"]

        # Duplicate signup should return 409
        res_dup = await client.post("/v1/auth/signup", json=signup_payload)
        assert res_dup.status_code == 409

        # 2. Login
        login_payload = {
            "email": test_email,
            "password": test_password,
        }
        res_login = await client.post("/v1/auth/login", json=login_payload)
        assert res_login.status_code == 200
        login_data = res_login.json()
        assert login_data["access_token"] is not None

        # Invalid login
        bad_login = await client.post(
            "/v1/auth/login",
            json={"email": test_email, "password": "WrongPassword!"},
        )
        assert bad_login.status_code == 401

        # 3. Get /auth/me
        headers = {"Authorization": f"Bearer {access_token}"}
        res_me = await client.get("/v1/auth/me", headers=headers)
        assert res_me.status_code == 200
        assert res_me.json()["email"] == test_email

        # 4. Token refresh
        res_refresh = await client.post(
            "/v1/auth/refresh",
            json={"refresh_token": refresh_token},
        )
        assert res_refresh.status_code == 200
        new_tokens = res_refresh.json()
        assert "access_token" in new_tokens
        assert "refresh_token" in new_tokens

        # 5. Forgot password & reset password flow
        # Request reset OTP
        res_forgot = await client.post(
            "/v1/auth/forgot-password",
            json={"email": test_email},
        )
        assert res_forgot.status_code == 200

        # Retrieve the generated OTP from database for testing
        async with AsyncSessionLocal() as session:
            user = await auth_service.get_user_by_email(session, test_email)
            assert user is not None
            # Retrieve latest OTP
            from sqlalchemy import select, desc
            from app.models.user import PasswordResetToken
            stmt = select(PasswordResetToken).where(PasswordResetToken.user_id == user.id).order_by(desc(PasswordResetToken.created_at))
            otp_record = (await session.execute(stmt)).scalars().first()
            assert otp_record is not None
            otp_code = otp_record.otp_code

        # Verify OTP
        res_verify = await client.post(
            "/v1/auth/verify-otp",
            json={"email": test_email, "otp": otp_code},
        )
        assert res_verify.status_code == 200

        # Reset Password
        new_password = "NewSecurePassword456!"
        res_reset = await client.post(
            "/v1/auth/reset-password",
            json={"email": test_email, "otp": otp_code, "new_password": new_password},
        )
        assert res_reset.status_code == 200

        # Log in with new password
        res_new_login = await client.post(
            "/v1/auth/login",
            json={"email": test_email, "password": new_password},
        )
        assert res_new_login.status_code == 200
        new_access_token = res_new_login.json()["access_token"]

        # 6. Dashboard summary with new auth token
        new_headers = {"Authorization": f"Bearer {new_access_token}"}
        res_dash = await client.get("/v1/dashboard/summary", headers=new_headers)
        assert res_dash.status_code == 200
        dash_data = res_dash.json()
        assert "stats" in dash_data
        assert "recent_fields" in dash_data
        assert "active_alerts" in dash_data
        assert len(dash_data["stats"]) > 0
        assert len(dash_data["recent_fields"]) > 0

        # 7. Dashboard alerts list
        res_alerts = await client.get("/v1/dashboard/alerts", headers=new_headers)
        assert res_alerts.status_code == 200
        alerts_data = res_alerts.json()
        assert "alerts" in alerts_data
        assert "total" in alerts_data

        # 8. Unauthenticated access check
        res_unauth = await client.get("/v1/dashboard/summary")
        assert res_unauth.status_code == 401
