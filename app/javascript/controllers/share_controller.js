import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="share"
export default class extends Controller {

  static targets = ["sharedMessage"]
  static values = { url: String, title: String, text: String }

  connect() {
    this.isSharing = false
  }

  async share() {

    const successClasses = ["mt-1", "bg-ok-subtle", "border", "border-ok", "text-ok"]
    const errorClasses = ["mt-1", "bg-danger-subtle", "border", "border-danger", "text-danger"]

    if (navigator.share) {
      // navigator.shareが対応している場合
      if (this.isSharing) return
      this.isSharing = true

      try {

        await navigator.share({
          title: this.titleValue,
          text: this.textValue,
          url: this.urlValue
        });
        this.showMessage("成功しました！", successClasses)
      } catch (err) {
        if (err.name === "AbortError") return
        console.error("取得できませんでした", err.message);
        this.showMessage("失敗しました...", errorClasses)
      } finally {
        this.isSharing = false

      }
    } else {
      // 対応していない場合、クリップボードにコピー
      try {
        await navigator.clipboard.writeText(this.urlValue)
        this.showMessage("成功しました！", ["mt-1", "bg-ok-subtle", "border", "border-ok", "text-ok"])
      } catch (err) {
        console.error("取得できませんでした", err.message);
        this.showMessage("失敗しました...", ["mt-1", "bg-danger-subtle", "border", "border-danger", "text-danger"])
      }
    }
  }

  showMessage(text, classes) {
    const stateClasses = ["mt-1", "bg-ok-subtle", "border", "border-ok", "text-ok", "bg-danger-subtle", "border", "border-danger", "text-danger"]

    this.sharedMessageTarget.textContent = text
    this.sharedMessageTarget.classList.remove(...stateClasses)
    this.sharedMessageTarget.classList.add(...classes)
    setTimeout(() => {
      this.sharedMessageTarget.classList.remove(...stateClasses)
      this.sharedMessageTarget.textContent = ""
    }, 2000);
  }
}
