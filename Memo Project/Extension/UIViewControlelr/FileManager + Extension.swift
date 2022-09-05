import UIKit

extension UIViewController {
    
    func createTextFileToDocumentDirectory(text: String) {
        guard let documentDirectoryURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else { return }
        
        let textfileURL = documentDirectoryURL.appendingPathComponent("텍스트 파일.txt")
        let newText = NSString(string: text)
        
        if FileManager.default.fileExists(atPath: textfileURL.path) {
            print("해당 파일이 이미 존재합니다")
        } else {
            do {
                try newText.write(to: textfileURL, atomically: false, encoding: String.Encoding.utf8.rawValue)
                print("텍스트 파일이 생성됐습니다.")
            } catch let erorr {
                print("텍스트 파일에 내용 추가 실패", erorr)
            }
        }
        
    }
    
    func deleteTextFileFromDocumentDirectory() {
        guard let textFileURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first?.appendingPathComponent("텍스트 파일.txt") else { return }

        do {
            try FileManager.default.removeItem(at: textFileURL)
        } catch let error {
            print("텍스트 파일 삭제 실패", error)
        }
    }
    
    func showActivityViewController() {
        guard let documentDirectoryURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else {
            print("도큐먼트 경로가 올바르지 않음")
            return }
        
        let textfileURL = documentDirectoryURL.appendingPathComponent("텍스트 파일.txt")
        
        let vc = UIActivityViewController(activityItems: [textfileURL], applicationActivities: nil)
        
        vc.completionWithItemsHandler = { (activity, success, items, error) in
            if success {
                self.deleteTextFileFromDocumentDirectory()
                print("작업이 성공하여 해당 파일을 삭제합니다.")
            } else {
                print("작업을 취소 또는 실패하여 삭제되지 않았습니다.")
            }
        }
        
        self.present(vc, animated: true)
    }
}

