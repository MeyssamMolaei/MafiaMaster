import SwiftUI
import AVFoundation

struct MafiaGameView: View {
	@AppStorage("playersText") private var playersText = ""
	@AppStorage("rolesText") private var rolesText = ""
	@State private var gameState = "setup"
	@State private var playerList: [String] = []
	@State private var roleList: [String] = []
	@State private var assignments: [(player: String, role: String)] = []
	@State private var currentIndex = 0
	@State private var showRole = false
	@State private var confirmEnd = false
	var player: AVAudioPlayer?
	

	@available(iOS 16.0, *)
	var body: some View {
		VStack(spacing: 20) {
			if gameState == "setup" {
				Text("نام بازکنان و نقشها را وارد کنید")
					.font(.headline)
				VStack(alignment: .leading) {
					Text("بازیکنان:")
					TextEditor(text: $playersText)
						.frame(width: UIScreen.main.bounds.width * 0.9, height: UIScreen.main.bounds.height * 0.30)
						.border(Color.gray)
						.toolbar {
							ToolbarItem(placement: .keyboard) {
//								Spacer()
								Button("Close") {
									hideKeyboard()
								}
							}
						}
						
				}
				.environment(\.layoutDirection, .rightToLeft)
				.flipsForRightToLeftLayoutDirection(false)
				VStack(alignment: .leading) {
					Text("نقش ها:")
					TextEditor(text: $rolesText)
						.frame(width: UIScreen.main.bounds.width * 0.9, height: UIScreen.main.bounds.height * 0.30)
						.border(Color.gray)
						.toolbar {
							ToolbarItem(placement: .keyboard) {
								Spacer()
								Button("Close") {
									hideKeyboard()
								}
							}
						}
				}
				.environment(\.layoutDirection, .rightToLeft)
				.flipsForRightToLeftLayoutDirection(false)
				Button("آماده؟") {
					startGame()
				}
				.padding()
				.background(Color.blue)
				.foregroundColor(.white)
				.cornerRadius(10)
			} else if gameState == "playing" {
				Text("\n \(playerList[currentIndex])")
					.font(.largeTitle)
				if showRole {
					Text("در نقش \(roleList[currentIndex])")
						.font(.title)
				}
				Button(showRole ? "بعدی" : "نقش منو نشون بده") {
					playBeep()
					assignRole()

				}
				.padding()
				.background(Color.green)
				.foregroundColor(.white)
				.cornerRadius(10)
			} else if gameState == "confirmation" && !confirmEnd {
				Text("همه بازیکن ها نقشهاشون رو گرفتن؟")
				Button("بله بهم لیست بازکنها رو نشون بده") {
					confirmGameEnd()
				}
				.padding()
				.background(Color.red)
				.foregroundColor(.white)
				.cornerRadius(10)
			} else if confirmEnd {
				VStack {
					Text("لیست بازیکنان و نقشها")
						.font(.headline)
					TableView(assignments: assignments.sorted(by: {
						guard let indexA = roleList.firstIndex(of: $0.role), let indexB = roleList.firstIndex(of: $1.role) else {
							return false
						}
						return indexA < indexB
					}))
				}
				.environment(\.layoutDirection, .rightToLeft)
				.flipsForRightToLeftLayoutDirection(false)
			}
		}
		.padding()
	}
	
	private func startGame() {
		let playerArr = playersText.split(separator: "\n").map { $0.trimmingCharacters(in: .whitespaces) }.filter { !$0.isEmpty }
		let roleArr = rolesText.split(separator: "\n").map { $0.trimmingCharacters(in: .whitespaces) }.filter { !$0.isEmpty }
		
		guard playerArr.count == roleArr.count else {
			return
		}
		
		playerList = playerArr
		roleList = roleArr.shuffled()
		assignments = []
		gameState = "playing"
		currentIndex = 0
	}
	
	private func assignRole() {
		if !showRole {
			assignments.append((player: playerList[currentIndex], role: roleList[currentIndex]))
			showRole = true
		} else {
			showRole = false
			if currentIndex + 1 < playerList.count {
				currentIndex += 1
			} else {
				gameState = "confirmation"
			}
		}
	}
	
	private func confirmGameEnd() {
		confirmEnd = true
	}
}

struct NumberedTextEditor: View {
	@Binding var text: String
	
	var body: some View {
		HStack {
			ScrollView(.vertical) {
				VStack(alignment: .trailing) {
					ForEach(0..<(text.split(separator: "\n").count + 1), id: \ .self) { i in
						Text("\(i + 1)")
							.foregroundColor(.gray)
							.frame(width: 30, alignment: .trailing)
					}
				}
			}
			TextEditor(text: $text)
				.frame(height: UIScreen.main.bounds.height * 0.30)
				.border(Color.gray)
		}
	}
}

struct TableView: View {
	let assignments: [(player: String, role: String)]
	
	var body: some View {
		VStack {
			HStack {
				Text("#").bold().frame(width: 30)
				Text("نقش").bold().frame(maxWidth: .infinity, alignment: .leading)
				Text("بازیکن").bold().frame(maxWidth: .infinity, alignment: .leading)
			}
			.padding()
			.background(Color.gray.opacity(0.2))
			
			ForEach(assignments.indices, id: \ .self) { index in
				HStack {
					Text("\(index + 1)").frame(width: 30)
					Text(assignments[index].role).frame(maxWidth: .infinity, alignment: .leading)
					Text(assignments[index].player).frame(maxWidth: .infinity, alignment: .leading)
				}
				.padding()
				.frame(height: 30)
				.background(index % 2 == 0 ? Color.clear : Color.gray.opacity(0.1))
			}
		}
	}
}

struct ContentView_Previews: PreviewProvider {
	static var previews: some View {
		MafiaGameView()
	}
}
extension View {
	func hideKeyboard() {
		UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
	}
}
func playBeep() {
	AudioServicesPlaySystemSound(1016) // System beep sound
}

@main
struct MafiaGameApp: App {
	var body: some Scene {
		WindowGroup {
			MafiaGameView()
		}
	}
}
