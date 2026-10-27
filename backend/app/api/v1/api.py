from fastapi import APIRouter

from app.api.v1.endpoints import (
    auth,
    dashboard,
    users,
    farms,
    crop_scans,
    soil,
    recommendations,
    ai,
    sensors,
    weather,
)

api_router = APIRouter()

api_router.include_router(auth.router)
api_router.include_router(dashboard.router)
api_router.include_router(users.router)
api_router.include_router(farms.router)
api_router.include_router(crop_scans.router)
api_router.include_router(soil.router)
api_router.include_router(recommendations.router)
api_router.include_router(ai.router)
api_router.include_router(sensors.router)
api_router.include_router(weather.router)
