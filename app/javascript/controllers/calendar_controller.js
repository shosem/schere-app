import { Controller } from "@hotwired/stimulus"

const DAYS = [ "日", "月", "火", "水", "木", "金", "土" ]
const MONTHS = [ "1月", "2月", "3月", "4月", "5月", "6月", "7月", "8月", "9月", "10月", "11月", "12月" ]

const toDateStr = (year, month, day) => {
  const yyyy = year
  const mm = String(month + 1).padStart(2, "0")
  const dd = String(day).padStart(2, "0")
  return `${yyyy}-${mm}-${dd}`
}

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
    console.log(toDateStr(this.year, this.month, 1))

  }

  toggle(e) {
    e.preventDefault()
    const clickedDate = e.currentTarget.dataset.date

    // 選択済みにあるかどうか
    if (this.selected.has(clickedDate)){

      // ある場合は削除
      this.selected.delete(clickedDate)

    } else {

      // ない場合は追加
      this.selected.set(clickedDate, { startTime: "", endTime: "" })
    }
    console.log(this.selected)
    this.renderCalendar()
  }

  // カレンダー表示関数
  renderCalendar() {
    this.monthLabelTarget.textContent = `${this.year}年${MONTHS[this.month]}`

    const firstDay = new Date(this.year, this.month, 1).getDay()

    const finalDate = new Date(this.year, (this.month+1), 0).getDate()

    const now = new Date()

    const today = toDateStr(now.getFullYear(), now.getMonth(), now.getDate())
    
    // htmlを用意する。縦枠が7つあるもの
    let html = '<div class="grid grid-cols-7 text-center mb-1">'

    // 日〜土まで並べる。カレンダーの曜日ラベル
    DAYS.forEach((d) => {
      html += `<div class="text-xs font-medium text-gray-400 py-1">${d}</div>`
    })
    
    // 曜日ラベルの枠を閉じ、日付の枠を追加
    html += `</div><div class="grid grid-cols-7 text-center gap-y-1">`

    // 初日の曜日まで空きマスを作る
    for(let i = 0; i < firstDay; i++) {
      html += "<div></div>"
    }

    // その月の日数を注ぎ込む
    for(let d = 1; d <= finalDate; d++) {
      const targetDate = toDateStr(this.year, this.month, d)

      let cls = ""
        // 過去
        if(targetDate < today) {
        // グレー＋押せない
          cls = "bg-gray-300"

        // 選択済み
        } else if(this.selected.has(targetDate)){
        
          cls = "bg-blue-500 text-white font-bold cursor-pointer"

        // 今日
        } else if(targetDate === today){
        // アクセント
          cls = "text-blue-500 font-semibold hover:bg-blue-50 cursor-pointer"
        
        // 通常
        } else {
          cls = "text-gray-700 hover:bg-gray-100 cursor-pointer"
        }

      const action = targetDate < today ? "" : `data-action='click->calendar#toggle' data-date="${targetDate}"`
     
      html += `<button type="button" class="${cls}" ${action}>${d}</button>`
    }

    html += "</div>"
  
    this.gridTarget.innerHTML = html
  }
}
