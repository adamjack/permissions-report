//
//  Copyright (c) 2016 Google Inc.
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//  http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.
//

import UIKit
import Firebase
import FirebaseUI

class PermissionsViewController: UIViewController {

    @IBOutlet var log : UITextView? = nil
    
    override func viewDidLoad() {
        
        super.viewDidLoad()

        self.title = "Permissions Report"
        navigationController?.navigationBar.tintColor = UIColor.white

        log?.text = "Press 'Login' to get an anonymous account"
    }

    deinit {
    
    
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }


    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }

    @IBAction func login() {

        Auth.auth().signInAnonymously() { (authResult, error) in

            print("Auth : [\(String(describing: authResult))] [\(String(describing: error))]")
            if ( nil == error ) {
                self.log?.text = "Logged in. Perform Tests."
            }
            else {
                print("User : [\(String(describing: Auth.auth().currentUser)))]")
            }
        }

    }
    
    @IBAction func test1() {
        
        // Logged in ok?
        if let userId =  Auth.auth().currentUser?.uid {
            
            let db = Firestore.firestore()
            
            var eventData = [String:Any]()
            eventData["name"] = "test1"
            eventData["userId"] = userId

            let eventRef = db.collection("events").addDocument(data: eventData)
            
            let query = eventRef.collection("notes").limit(to: 50)
            let listener = query.addSnapshotListener { [unowned self] (snapshot, error) in

                let message = "Snapshot : [\(String(describing: snapshot))] \n Error: [\(String(describing: error))]"
                print(message)
                self.log?.text = message
                
            }
            
            print("Listener: [\(listener)]")
        }
        else {
            let message = "Login before attempting tests"
            print(message)
            self.log?.text = message
        }
    }
    
    
    @IBAction func test2() {
        
        // Logged in ok?
        if let userId =  Auth.auth().currentUser?.uid {
            
            let db = Firestore.firestore()
            
            var eventData = [String:Any]()
            eventData["name"] = "test2"
            eventData["userId"] = userId
            let eventRef = db.collection("events").addDocument(data: eventData)
            let query = eventRef.collection("notes").limit(to: 50)
            
            test2listen(query:query,attempt:1)
        }
        else {
            let message = "Login before attempting tests"
            print(message)
            self.log?.text = message
        }
    }
    
    func test2listen(query:Query,attempt:Int) {
        
        let listener = query.addSnapshotListener { [unowned self] (snapshot, error) in
    
            let message = "Attempt [#\(attempt)] Snapshot : [\(String(describing: snapshot))] \n Error: [\(String(describing: error))]"
            print(message)
            self.log?.text = message

            // Not forever...
            if ( attempt > 100 ) {
                return
            }
            
            // Got permissions error? Try again in a sec...
            if let error = error as NSError?,
                error.code == FirestoreErrorCode.permissionDenied.rawValue {
                
                // Retry ...
                DispatchQueue.main.asyncAfter(
                    deadline: DispatchTime.now() + Double(Int64(1.0 * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC), execute: {
                        
                        self.test2listen(query: query, attempt: 1 + attempt)
                        
                })
                
            }
            else {
                
                let message = "Attempt [#\(attempt)] Snapshot : [\(String(describing: snapshot))] \n Error: [\(String(describing: error))]"
                print(message)
                self.log?.text = message
                
            }
        
        }
        
        print("Listener: [\(listener)]")

    
    }
    
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        set {}
        get {
          return .lightContent
        }
    }

  
}
