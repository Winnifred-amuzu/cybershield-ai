from fastapi import APIRouter

from ..models.schemas import DashboardResponse
from ..services.database import get_history_dataframe

router = APIRouter(prefix="/dashboard", tags=["Dashboard"])


@router.get("", response_model=DashboardResponse)
def dashboard():
    df = get_history_dataframe()

    if df.empty:
        return DashboardResponse(
            total_scans=0,
            threats_found=0,
            safe_scans=0,
            scam_scans=0,
            distribution={},
        )

    total_scans = len(df)
    scam_scans = int((df["prediction"] != "SAFE").sum())
    safe_scans = int((df["prediction"] == "SAFE").sum())

    distribution = {
        str(key): int(value)
        for key, value in df["prediction"].value_counts().to_dict().items()
    }

    return DashboardResponse(
        total_scans=total_scans,
        threats_found=scam_scans,
        safe_scans=safe_scans,
        scam_scans=scam_scans,
        distribution=distribution,
    )
