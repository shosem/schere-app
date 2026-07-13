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
    this.renderSelected()
    console.log(toDateStr(this.year, this.month, 1))
    this.syncFields()

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
    this.renderSelected()
    this.syncFields()
  }

  // 入力した時間を更新する関数
  updateTime(e){

    // 変更があった日付と値を取得
    const { date, field } = e.currentTarget.dataset
    const changedValue = e.currentTarget.value

    // 変更があった日付のMapの要素を取得
    const times = this.selected.get(date)
    if (field === "start"){
      times.startTime = changedValue
    } else {
      times.endTime = changedValue
    }
    this.syncFields()
  }

  // 削除機能
  removeDate(e){
    const date = e.currentTarget.dataset.date
    this.selected.delete(date)
    this.renderCalendar()
    this.renderSelected()
    this.syncFields()
  }

  prevMonth(){
    this.month -= 1
    if(this.month < 0){
      this.month = 11
      this.year -= 1
    }
    this.renderCalendar()
  }

  nextMonth(){
    this.month += 1
    if(this.month > 11){
      this.month = 0
      this.year += 1
    }
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

  // 選択済みの日付を表示する関数
  renderSelected(){

    // 空のhtml用意
    let html = ""

    // 選択済みが空なら文章を出す
    if (this.selected.size === 0) {
      this.selectedListTarget.textContent = "候補日が選択されていません"
      return
    }

    // 選択済みの日付を配列にして昇順にする
    const selectedDays = [...this.selected.keys()].sort()
    
    // 配列の要素を一個ずつ表示。timeの入力欄も。
    selectedDays.forEach((sd) => {
      const { startTime, endTime } = this.selected.get(sd)

      html += `<div>
                 ${sd}
                 <input type="time" value="${startTime}" data-date="${sd}" data-field="start" data-action='change->calendar#updateTime'>
                 <input type="time" value="${endTime}" data-date="${sd}" data-field="end" data-action='change->calendar#updateTime'>
                 <button type="button" data-date="${sd}" data-action='click->calendar#removeDate' class="border px-2">x</button>
              </div>`
    })

    this.selectedListTarget.innerHTML = html
  }

  syncFields(){
    const selectedDays = [...this.selected.keys()].sort()
    let html = ""
    let i = 0
    selectedDays.forEach((sd) => {
      const { startTime, endTime } = this.selected.get(sd)

      html += `<input type="hidden" name="event[candidate_dates_attributes][${i}][date]" value="${sd}">`

      if(startTime){
        html += `<input type="hidden" name="event[candidate_dates_attributes][${i}][start_time]" value="${startTime}">`
      }
      if(endTime){
        html += `<input type="hidden" name="event[candidate_dates_attributes][${i}][end_time]" value="${endTime}">`
      }
      i ++
    })

    this.hiddenContainerTarget.innerHTML = html
  }
}
