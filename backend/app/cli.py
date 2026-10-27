import asyncio
import click
from sqlalchemy import select
from app.core.database import AsyncSessionLocal, init_db, engine
from app.models.user import User
from app.models.dashboard import Field, Alert
from app.core.security import get_password_hash
import uuid


@click.group()
def cli():
    """Database management CLI."""
    pass


@cli.group()
def db():
    """Database commands."""
    pass


@db.command()
def init():
    """Initialize database (run migrations to latest)."""
    import os
    click.echo("Running Alembic migrations...")
    os.system("alembic upgrade head")
    click.echo("✓ Database initialized")


@db.command()
def seed():
    """Seed database with sample data for development."""
    async def _seed():
        async with AsyncSessionLocal() as session:
            # Check if admin exists
            stmt = select(User).where(User.email == "admin@khetopedia.com")
            result = await session.execute(stmt)
            existing = result.scalars().first()
            
            if existing:
                click.echo("Admin user already exists, skipping seed")
                return
            
            # Create admin user
            admin = User(
                id=str(uuid.uuid4()),
                email="admin@khetopedia.com",
                phone="+911234567890",
                name="Admin User",
                hashed_password=get_password_hash("admin123"),
                is_superuser=True,
                is_active=True,
                is_email_verified=True,
            )
            session.add(admin)
            await session.flush()
            
            # Create sample fields
            field1 = Field(
                id=str(uuid.uuid4()),
                user_id=admin.id,
                name="North Field",
                acreage=2.5,
                crop_name="Wheat",
                health_score=85,
                latitude=28.6139,
                longitude=77.2090,
            )
            field2 = Field(
                id=str(uuid.uuid4()),
                user_id=admin.id,
                name="South Field",
                acreage=3.2,
                crop_name="Rice",
                health_score=78,
                latitude=28.6100,
                longitude=77.2100,
            )
            session.add_all([field1, field2])
            await session.flush()
            
            # Create sample alert
            alert = Alert(
                id=str(uuid.uuid4()),
                user_id=admin.id,
                field_id=field1.id,
                title="Pest Detection",
                message="Aphids detected in North Field. Immediate action recommended.",
                severity="critical",
                alert_type="disease",
                is_read=False,
            )
            session.add(alert)
            
            await session.commit()
            click.echo("✓ Seeded database with:")
            click.echo(f"  - Admin user: admin@khetopedia.com / admin123")
            click.echo(f"  - 2 sample fields")
            click.echo(f"  - 1 sample alert")
    
    asyncio.run(_seed())


@db.command()
@click.confirmation_option(prompt="This will delete all data. Are you sure?")
def reset():
    """Drop all tables and re-run migrations (dev only)."""
    import os
    click.echo("Dropping all tables...")
    
    async def _drop_all():
        async with engine.begin() as conn:
            await conn.run_sync(lambda sync_conn: sync_conn.execute("DROP TABLE IF EXISTS alembic_version CASCADE"))
            from app.core.database import Base
            await conn.run_sync(Base.metadata.drop_all)
    
    asyncio.run(_drop_all())
    click.echo("✓ Tables dropped")
    
    click.echo("Re-running migrations...")
    os.system("alembic upgrade head")
    click.echo("✓ Database reset complete")


@db.command()
@click.option("--message", "-m", required=True, help="Migration message")
def migrate(message):
    """Create new migration."""
    import os
    click.echo(f"Creating migration: {message}")
    os.system(f'alembic revision --autogenerate -m "{message}"')
    click.echo("✓ Migration created")


if __name__ == "__main__":
    cli()
