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
    this.checkedProjects = this.loadCheckedIds("project")
    this.checkedTasks = this.loadCheckedIds("task")

    this.removeCheckedGridItems()
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
    const projects = this.filterCheckedItems(this.parseDataset(cell.dataset.projects), "project")
    const tasks = this.filterCheckedItems(this.parseDataset(cell.dataset.tasks), "task")
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
      li.textContent = item.name
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

  loadCheckedIds(type) {
    const key = type === "project" ? "checkedProjects" : "checkedTasks"

    try {
      const raw = localStorage.getItem(key)
      return raw ? JSON.parse(raw) : []
    } catch (error) {
      console.warn("チェック状態の読み込みに失敗しました", error)
      return []
    }
  }

  filterCheckedItems(items, type) {
    const ignoredIds = new Set(type === "project" ? this.checkedProjects : this.checkedTasks)
    return items.filter((item) => !ignoredIds.has(String(item.id)))
  }

  removeCheckedGridItems() {
    const projectIds = new Set(this.checkedProjects)
    const taskIds = new Set(this.checkedTasks)

    this.cellTargets.forEach((cell) => {
      const items = cell.querySelectorAll("[data-calendar-item-type]")

      items.forEach((item) => {
        const type = item.dataset.calendarItemType
        const id = item.dataset.calendarItemId

        if ((type === "project" && projectIds.has(id)) || (type === "task" && taskIds.has(id))) {
          item.remove()
        }
      })
    })
  }
}