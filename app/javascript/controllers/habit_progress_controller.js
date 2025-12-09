import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["checkbox", "progress"]
  static values = { totalDays: Number }
  static values = { totalDays: Number, updateUrl: String }

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

  toggle(event) {
    const checkbox = event.target
    const checkDate = checkbox.value
    const completed = checkbox.checked

    this.recalculate()

    if (!this.hasUpdateUrlValue) return

    fetch(this.updateUrlValue, {
      method: "PATCH",
      headers: {
        "Content-Type": "application/json",
        "X-CSRF-Token": this.#csrfToken(),
        Accept: "application/json",
      },
      body: JSON.stringify({ check_date: checkDate, completed }),
    })
      .then((response) => {
        if (!response.ok) throw new Error("Request failed")
        return response.json()
      })
      .then((data) => {
        if (data?.progress_text) {
          this.progressTarget.textContent = data.progress_text
        } else {
          this.recalculate()
        }
      })
      .catch(() => {
        checkbox.checked = !completed
        this.recalculate()
      })
  }

  #csrfToken() {
    const element = document.querySelector("meta[name='csrf-token']")
    return element?.content
  }
}