import { Controller } from "@hotwired/stimulus"

const DAYS = [ "日", "月", "火", "水", "木", "金", "土" ]
const MONTHS = [ "1月", "2月", "3月", "4月", "5月", "6月", "7月", "8月", "9月", "10月", "11月", "12月" ]

// Connects to data-controller="calendar"
export default class extends Controller {
  static targets = ["grid", "monthLabel", "selectedList", "hiddenContainer"]

  initialize() {
    const now = new Date()
    this.year = now.getFullYear()
    this.month = now.getMonth()
    this.selected = new Map()
  }
  connect() {
    console.log("calendar connected!")
    this.renderCalendar()

  }

  // カレンダー表示関数
  renderCalendar() {
    this.monthLabelTarget.textContent = `${this.year}年${MONTHS[this.month]}`

    const firstDay = new Date(this.year, this.month, 1).getDay()

    const finalDate = new Date(this.year, (this.month+1), 0).getDate()
    
    // htmlを用意する。縦枠が7つあるもの
    let html = '<div class="grid grid-cols-7 text-center mb-1">'

    // 日〜土まで並べる。カレンダーの曜日ラベル
    DAYS.forEach((d) => {
      html += `<div>${d}</div>`
    })
    
    // 曜日ラベルの枠を閉じ、日付の枠を追加
    html += `</div><div class="grid grid-cols-7 text-center mb-1">`

    // 初日の曜日まで空きマスを作る
    for(let i = 0; i < firstDay; i++) {
      html += "<div></div>"
    }

    // その月の日数を注ぎ込む
    for(let d = 1; d <= finalDate; d++) {
      html += `<button type="button">${d}</button>`
    }

    html += "</div>"
  
    this.gridTarget.innerHTML = html
  }
}
