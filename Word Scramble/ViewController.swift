//
//  ViewController.swift
//  Word Scramble
//
//  Created by Camilo Hernández Guerrero on 22/06/22.
//

import UIKit

class ViewController: UITableViewController {
    var allWords = Array<String>()
    var usedWords = [String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Restart", style: .plain, target: self, action: #selector(startGame))
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(promptForAnswer))
        
        let defaults = UserDefaults.standard
        
        if let savedTitle = defaults.string(forKey: "currentWord") {
            title = savedTitle
        }
        
        if let savedWords = defaults.object(forKey: "usedWords") as? [String] {
            usedWords = savedWords
        }
        
        if let startWordsURL = Bundle.main.url(forResource: "start", withExtension: "txt") {
            if let startWords = try? String(contentsOf: startWordsURL) {
                allWords = startWords.components(separatedBy: "\n")
            }
        }
        
        if allWords.isEmpty {
            allWords = ["silkworm"]
        }
        
        if usedWords.isEmpty {
            startGame()
        }
    }
    
    @objc func startGame() {
        title = allWords.randomElement()
        UserDefaults.standard.set(title, forKey: "currentWord")
        usedWords.removeAll(keepingCapacity: true)
        tableView.reloadData()
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return usedWords.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Word", for: indexPath)
        cell.textLabel?.text = usedWords[indexPath.row]
        return cell
    }
    
    @objc func promptForAnswer() {
        let alertController = UIAlertController(title: "Enter answer", message: nil, preferredStyle: .alert)
        alertController.addTextField()
        
        let submitAction =  UIAlertAction(title: "Submit", style: .default) {
            [weak self, weak alertController] _ in
            guard let answer = alertController?.textFields?[0].text else {return}
            self?.submit(answer)
        }
        
        alertController.addAction(submitAction)
        present(alertController, animated: true)
    }
    
    func submit(_ answer: String) {
        let lowercassedAnswer = answer.lowercased()
        
        if !isEqual(word: lowercassedAnswer) {
            if hasMoreThanTwoChars(word: lowercassedAnswer) {
                if isPossible(word: lowercassedAnswer) {
                    if isOriginal(word: lowercassedAnswer) {
                        if isReal(word: lowercassedAnswer) {
                            usedWords.insert(lowercassedAnswer, at: 0)
                            
                            UserDefaults.standard.set(usedWords, forKey: "usedWords")
                            
                            let indexPath = IndexPath(row: 0, section: 0)
                            tableView.insertRows(at: [indexPath], with: .automatic)
                            
                            return
                        } else {
                            showErrorMessage(given: "Word not recognized", and: "You can't make them up.")
                        }
                    } else {
                        showErrorMessage(given: "Word already used", and: "Be original.")
                    }
                } else {
                    showErrorMessage(given: "Word not possible", and: "You can't spell that word from \(title!.lowercased()).")
                }
            } else {
                showErrorMessage(given: "Word has less than three characters", and: "Answers that short are not allowed.")
            }
        } else {
            showErrorMessage(given: "Word is exactly the same", and: "You type the same word as an answer.")
        }

    }
    
    func isEqual(word: String) -> Bool {
        guard let tempWord = title?.lowercased() else { return false }
        
        return word.elementsEqual(tempWord)
    }
    
    func hasMoreThanTwoChars(word: String) -> Bool {
        return word.count >= 3
    }
    
    func isPossible(word: String) -> Bool {
        guard var tempWord = title?.lowercased() else { return false }
        
        for letter in word {
            if let position = tempWord.firstIndex(of: letter) {
                tempWord.remove(at: position)
            } else {
                return false
            }
        }
        
        return true
    }
    
    func isOriginal(word: String) -> Bool {
        return !usedWords.contains(word)
    }
    
    func isReal(word: String) -> Bool {
        let checker = UITextChecker()
        let range = NSRange(location: 0, length: word.utf16.count)
        let missSpelledRange = checker.rangeOfMisspelledWord(in: word, range: range, startingAt: 0, wrap: false, language: "en")
        
        return missSpelledRange.location == NSNotFound
    }
    
    func showErrorMessage(given errorTitle: String, and errorMessage: String) {
        let alertController = UIAlertController(title: errorTitle, message: errorMessage, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "OK", style: .default))
        present(alertController, animated: true)
    }
}
