import { Controller } from "@hotwired/stimulus"

const STORAGE_KEYS = {
  project: "checkedProjects",
  task: "checkedTasks"
}

export default class extends Controller {
  static targets = ["checkbox"]

  connect() {
    this.checkedProjects = new Set(this.loadIds("project"))
    this.checkedTasks = new Set(this.loadIds("task"))

    this.checkboxTargets.forEach((checkbox) => {
      const type = checkbox.dataset.checklistType
      const id = checkbox.value
      const isChecked = this.isChecked(type, id)

      checkbox.checked = isChecked
      this.applyStyle(checkbox, isChecked)
    })
  }

  toggle(event) {
    const checkbox = event.target
    const type = checkbox.dataset.checklistType
    const id = checkbox.value
    const { checked } = checkbox

    this.persist(type, id, checked)
    this.applyStyle(checkbox, checked)
  }

  applyStyle(checkbox, isChecked) {
    const card = checkbox.closest(".project-card")
    if (!card) return

    card.classList.toggle("project-card--checked", isChecked)
  }

  persist(type, id, isChecked) {
    const key = STORAGE_KEYS[type]
    if (!key) return

    const ids = new Set(this.loadIds(type))

    if (isChecked) {
      ids.add(id)
    } else {
      ids.delete(id)
    }

    localStorage.setItem(key, JSON.stringify([...ids]))
  }

  loadIds(type) {
    const key = STORAGE_KEYS[type]
    if (!key) return []

    try {
      const raw = localStorage.getItem(key)
      return raw ? JSON.parse(raw) : []
    } catch (error) {
      console.warn("チェック済みの状態を読み込めませんでした", error)
      return []
    }
  }

  isChecked(type, id) {
    const ids = type === "project" ? this.checkedProjects : this.checkedTasks
    return ids.has(id)
  }
}