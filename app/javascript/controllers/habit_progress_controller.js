import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["checkbox", "progress"]
  static values = { totalDays: Number }

  connect() {
    this.recalculate()
  }

  recalculate() {
    const checkedCount = this.checkboxTargets.filter((checkbox) => checkbox.checked).length
    const totalDays = this.totalDaysValue || this.checkboxTargets.length

    if (totalDays > 0) {
      const percentage = Math.round((checkedCount / totalDays) * 100)
      this.progressTarget.textContent = `${checkedCount} / ${totalDays}日 (${percentage}%)`
    } else {
      this.progressTarget.textContent = "開始日を設定してください"
    }
  }
}