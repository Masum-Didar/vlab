import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  toggle(event) {
    event.preventDefault()
    event.stopPropagation()

    const sidebar = document.getElementById("sidebar")
    const overlay = document.getElementById("sidebar-overlay")
    const main = document.getElementById("main-content")
    const openIcon = document.getElementById("sidebar-open-icon")
    const closeIcon = document.getElementById("sidebar-close-icon")

    if (!sidebar) return

    const isClosed = sidebar.classList.contains("sidebar-hidden")

    if (isClosed) {
      sidebar.classList.remove("sidebar-hidden")
      if (overlay) overlay.classList.remove("d-none")
      if (main) main.classList.add("ms-sidebar")
      if (openIcon) openIcon.classList.add("d-none")
      if (closeIcon) closeIcon.classList.remove("d-none")
      document.body.style.overflow = ""
    } else {
      sidebar.classList.add("sidebar-hidden")
      if (overlay) overlay.classList.add("d-none")
      if (main) main.classList.remove("ms-sidebar")
      if (openIcon) openIcon.classList.remove("d-none")
      if (closeIcon) closeIcon.classList.add("d-none")
      document.body.style.overflow = ""
    }
  }

  close(event) {
    if (event) {
      event.preventDefault()
      event.stopPropagation()
    }

    const sidebar = document.getElementById("sidebar")
    const overlay = document.getElementById("sidebar-overlay")
    const main = document.getElementById("main-content")
    const openIcon = document.getElementById("sidebar-open-icon")
    const closeIcon = document.getElementById("sidebar-close-icon")

    if (sidebar) sidebar.classList.add("sidebar-hidden")
    if (overlay) overlay.classList.add("d-none")
    if (main) main.classList.remove("ms-sidebar")
    if (openIcon) openIcon.classList.remove("d-none")
    if (closeIcon) closeIcon.classList.add("d-none")
    document.body.style.overflow = ""
  }
}
