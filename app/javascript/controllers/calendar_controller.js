import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = [
    "cell",
    "detailDate",
    "projectList",
    "taskList",
    "habitList",
    "emptyMessage"
  ]

  connect() {
    this.selectedCell = null
    this.selectToday()
  }

  select(event) {
    const cell = event.currentTarget

    if (!cell) return

    this.highlight(cell)
    this.updateDetail(cell)
  }

  selectToday() {
    const todayCell = this.cellTargets.find((cell) => cell.classList.contains("calendar-cell--today"))

    if (todayCell) {
      this.highlight(todayCell)
      this.updateDetail(todayCell)
    }
  }

  highlight(cell) {
    if (this.selectedCell) {
      this.selectedCell.classList.remove("calendar-cell--selected")
    }

    cell.classList.add("calendar-cell--selected")
    this.selectedCell = cell
  }

  updateDetail(cell) {
    const projects = this.parseDataset(cell.dataset.projects)
    const tasks = this.parseDataset(cell.dataset.tasks)
    const habits = this.parseDataset(cell.dataset.habits)
    const hasAnyEntries = projects.length || tasks.length || habits.length

    this.detailDateTarget.textContent = cell.dataset.dateLabel
    this.toggleEmptyMessage(!hasAnyEntries)

    this.renderList(this.projectListTarget, projects, "project")
    this.renderList(this.taskListTarget, tasks, "task")
    this.renderList(this.habitListTarget, habits, "habit")
  }

  renderList(element, items, modifier) {
    element.innerHTML = ""

    items.forEach((item) => {
      const li = document.createElement("li")
      li.className = `detail-list__item detail-list__item--${modifier}`
      li.textContent = item
      element.appendChild(li)
    })
  }

  parseDataset(rawValue) {
    try {
      return rawValue ? JSON.parse(rawValue) : []
    } catch (error) {
      console.warn("予定の読み込みに失敗しました", error)
      return []
    }
  }

  toggleEmptyMessage(isEmpty) {
    this.emptyMessageTarget.hidden = !isEmpty
  }
}