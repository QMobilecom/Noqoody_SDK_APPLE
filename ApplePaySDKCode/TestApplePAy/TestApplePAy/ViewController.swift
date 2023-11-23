//
//  ViewController.swift
//  TestApplePAy
//
//  Created by mahmoud ali on 12/11/2023.
//

import UIKit
import NoqoodyPay
class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    @IBAction func actionPayNow(_ sender: Any) {
        self.getAccessTokenFromNoqoody()
    }
    
}

extension ViewController {
    
    func getAccessTokenFromNoqoody() {
        let semaphore = DispatchSemaphore (value: 0)
        let parameters = "grant_type=password&username=qmobile&password=S@o4*2Mpr$"
        let postData =  parameters.data(using: .utf8)
        var request = URLRequest(url: URL(string: "https://www.noqoodypay.com/sdk/token")!,timeoutInterval: Double.infinity)
        request.addValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        request.httpMethod = "POST"
        request.httpBody = postData

        let task = URLSession.shared.dataTask(with: request) { data, response, error in
          guard let data = data else {
            print(String(describing: error))
            semaphore.signal()
            return
          }
          print(String(data: data, encoding: .utf8)!)
            let json = (try? JSONSerialization.jsonObject(with: data, options: [])) as? [String:AnyObject]
            DispatchQueue.main.async {
                let dict = SharedClass.sharedInstance.getDictionary(json)
                self.openPayment(String.getString(dict["access_token"]))
            }
          semaphore.signal()
        }

        task.resume()
        semaphore.wait()
    }
    
    func openPayment(_ token: String) {
        let congig = ConfigModel(environment: .NooqodyEnviromentSandBox,
                                 callBackURL: "https://thedineoutapp.com",
                                 projectCode: "G2f4tN60H",
                                 clientSecret: "fW1RDhboTQPrHYspAC0wzJv@",
                                 token: token,
                                 amount: Double("1") ?? 0,
                                 customerEmail: "sfluper@gmail.com",
                                 customerMobile: "9870163660",
                                 customerName: "sazid",
                                 description: "Developed for testing purpose")
        
            let viewController = NooqodyPaymentSceneConfigurator.configure(config: congig)
            viewController.delegate = self
            self.navigationController?.pushViewController(viewController, animated: true)
    }
}

extension ViewController: NooqodyPaymentDelegate {

    func paymentSuccess(controller: NooqodyPaymentViewController, paymentModel: PaymentStatusModel) {
        controller.navigationController?.popViewController(animated: true)
        let message = "Transaction with refrence: \(paymentModel.reference) is succeed with transaction ID: \(paymentModel.transactionID)"
        let alertView = UIAlertController(title: "Success", message: message, preferredStyle: .alert)
        alertView.addAction(UIAlertAction(title: "Ok", style: .cancel, handler: nil))
        self.present(alertView, animated: true, completion: nil)
    }

    func paymentFailed(controller: NooqodyPaymentViewController, refrence: String, message: String) {
        controller.navigationController?.popViewController(animated: true)
        let alertView = UIAlertController(title: "Failed", message: message, preferredStyle: .alert)
        alertView.addAction(UIAlertAction(title: "Ok", style: .cancel, handler: nil))
        self.present(alertView, animated: true, completion: nil)
    }
}
