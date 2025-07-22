// app/javascript/controllers/report_button_controller.js
import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
    static values = { reportableType: String, reportableId: Number }

    connect() {
        console.log("ReportButtonController connected for:", this.reportableTypeValue, this.reportableIdValue);
    }

    triggerReportModal() {
        console.log("ReportButtonController: triggerReportModal called, dispatching event.");
        const event = new CustomEvent("report:open", {
            bubbles: true,
            cancelable: true,
            detail: {
                reportableType: this.reportableTypeValue,
                reportableId: this.reportableIdValue
            }
        });
        this.element.dispatchEvent(event);
    }
}
