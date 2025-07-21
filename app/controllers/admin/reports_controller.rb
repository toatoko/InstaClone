class Admin::ReportsController < Admin::AdminController
  def index
    @reports = Report.includes(:reporter, :reportable).order(created_at: :desc).page(params[:page])
  end

  def show
    @report = Report.find(params[:id])
  end

  def update
    @report = Report.find(params[:id])
    if @report.update(report_params)
      redirect_to admin_reports_path, notice: "Report updated."
    else
      render :show
    end
  end

  private

  def report_params
    params.require(:report).permit(:status)
  end
end
