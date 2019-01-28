//
//  ViewController.swift
//  ibeacon
//
//  Created by Zahra on 1/14/19.
//

import UIKit
import CoreLocation
import Foundation

let A = 1.0
let H = 1.0
var Xk = 0.0
var Pk = 1.0 // we have error
let Q = 0.0
var sortedBeacon = [CLBeacon]()

var cnt = 0

class ViewController: UIViewController ,CLLocationManagerDelegate {
    var rssi: [[Int]] = []
    var rssiArray1 : [Int] = []
    var rssiArray2 : [Int] = []
    var rssiArray3 : [Int] = []
    var rssiArray4 : [Int] = []
    var xPerson : Int = 0
    var yPerson : Int = 0
    var flag = true
    //MARK: Properties
    @IBOutlet weak var ble1: UIImageView!
    @IBOutlet weak var ble2: UIImageView!
    @IBOutlet weak var ble3: UIImageView!
    @IBOutlet weak var ble4: UIImageView!
    @IBOutlet weak var person: UIImageView!
    var m1 : Double = 0.0
    var m2 : Double = 0.0

    let locationManager = CLLocationManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        (m1,m2) = triangulation(x: [10,0,5], y: [0,0,8], d: [10.38,12.06,7.07])
        print("m1 is :\(m1),m2 is :\(m2)")
        // Do any additional setup after loading the view, typically from a nib.
        person.frame = CGRect(x: xPerson, y: yPerson, width: 50, height: 50)
        self.initLocating()
        self.startLocating()
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    ///////////////////////////////////////////////////////////////
    
    func initLocating() {
        if CLLocationManager.isRangingAvailable() {
            self.locationManager.requestWhenInUseAuthorization()
            self.locationManager.desiredAccuracy = kCLLocationAccuracyThreeKilometers
            self.locationManager.allowsBackgroundLocationUpdates = true
            self.locationManager.delegate = self
        }
    }
   
    ///////////////////////////////////////////////////////////////
    
    func startLocating() {
        locationManager.pausesLocationUpdatesAutomatically = false
        self.locationManager.startUpdatingLocation()
        //self.rangeBeacons()
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if locations.count > 0 {
            Xk = 0.0
            Pk = 1.0 // we have error
            rssi.removeAll()
        }
    }

    ////////////////////////////////////////////////////////////////
    
    func rangeBeacons() {
        let uuid = UUID(uuidString :"74278bda-b644-4520-8f0c-720eaf059935")!
        let region = CLBeaconRegion(proximityUUID: uuid, identifier: "iTriplez")
        locationManager.startRangingBeacons(in: region)
    }
    
    ////////////////////////////////////////////////////////////////
    
    func getDefaultBeacons() -> [(UUID, CLBeaconMajorValue, CLBeaconMinorValue, Int, Int)] { // [(uuid, major, minor, x, y)]
        let DefaultBeacons : [(UUID, CLBeaconMajorValue, CLBeaconMinorValue, Int, Int)] = [
            ( UUID(uuidString :"74278bda-b644-4520-8f0c-720eaf059935")!, CLBeaconMajorValue(4369), CLBeaconMinorValue(1), 0 , 0 ),
            ( UUID(uuidString :"74278bda-b644-4520-8f0c-720eaf059935")!, CLBeaconMajorValue(4369), CLBeaconMinorValue(2), 10, 0 ),
            ( UUID(uuidString :"74278bda-b644-4520-8f0c-720eaf059935")!, CLBeaconMajorValue(4369), CLBeaconMinorValue(3), 0 , 0 ),
            ( UUID(uuidString :"74278bda-b644-4520-8f0c-720eaf059935")!, CLBeaconMajorValue(4369), CLBeaconMinorValue(4), 5, 8 ) ]
        return DefaultBeacons
    }
    
    ////////////////////////////////////////////////////////////////
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status == .authorizedAlways {
            self.rangeBeacons()
        }
    }
    
    ////////////////////////////////////////////////////////////////
    
    func locationManager(_ manager: CLLocationManager, didRangeBeacons beacons: [CLBeacon], in region: CLBeaconRegion) {
        
        guard (beacons.first?.proximity) != nil else { print("Couldn't find the beacon!"); return }
        
//        print(beacons)
        
        sortedBeacon = beacons.sorted(by: { $0.rssi < $1.rssi }) // or proximity
      
        for i in 0...3 {
            if sortedBeacon.count > 0 {
                if sortedBeacon.first?.minor == 1 {
                    rssiArray1.append((sortedBeacon.first?.rssi)!)
                }
                else if sortedBeacon.first?.minor == 2 {
                    rssiArray2.append((sortedBeacon.first?.rssi)!)
                  
                }
                else if sortedBeacon.first?.minor == 3 {
                    rssiArray3.append((sortedBeacon.first?.rssi)!)
                
                }
                else if sortedBeacon.first?.minor == 4 {
                    rssiArray4.append((sortedBeacon.first?.rssi)!)
                }
            }
       
            if sortedBeacon.count != 0{
                sortedBeacon.removeFirst()

            }
        }
        

        if rssiArray1.count > 10 {
            cnt += 1;
            rssiArray1.sort(by: {$0 > $1})
        }
        
        if rssiArray2.count > 10 {
            cnt += 1;
            rssiArray2.sort(by: {$0 > $1})
        }

        if rssiArray3.count > 10 {
            cnt += 1;
            rssiArray3.sort(by: {$0 > $1})
        }

        if rssiArray4.count > 10 {
            cnt += 1;
            rssiArray4.sort(by: {$0 > $1})
        }
        if cnt > 2 && flag == true {
            rssi.append(rssiArray1)
            rssi.append(rssiArray2)
            rssi.append(rssiArray3)
            rssi.append(rssiArray4)
            flag = false
            (xPerson,yPerson) = main()
            person.frame = CGRect(x: xPerson, y: yPerson, width: 50, height: 50)
            print("X person is : \(xPerson) and Y person is : \(yPerson)")
            rssi.removeAll()
        }

    }
    
    ////////////////////////////////////////////////////////////////
    
    func average( X : [Int], n : Int ) -> Double
    {
        var sum = 0
        for k in 0...n-1 {
            sum += X[k]
        }
        return Double(sum/n)
    }
    
    ////////////////////////////////////////////////////////////////
    
    func std( X : [Int], n : Int ) -> Double {
        
        let ave = average(X: X, n: n)
        var sum : Double = 0.0
        for i in 1...n-1 {
            sum += pow((Double(X[i]) - ave), 2)
        }
        return sqrt(Double(sum/Double(n-1)))
    }
    
    ////////////////////////////////////////////////////////////////
    
    func find_distance( rssi_p : Double, rssi_c : Double) -> Double{
        
        if rssi_p >= rssi_c {
            return pow(10, rssi_p/rssi_c)
        }
        else {
            return 0.9 * pow(7.71, rssi_p/rssi_c) + 0.11
        }
    }
    
    ////////////////////////////////////////////////////////////////
    
    func kalman_filter(RSSI : [Int], n : Int ) -> Double {
        
        // A=B=H=1 / Uk = 0 / p = error / R= khatayi ke mohasebe makane dare masalan hodud 0.5m / Q = 0
        // Zk = dade alan and Xk = x e ke pishbini mishe
        // Xk = Xk-1 / Pk = Pk-1 pishbini
        // Kk=Pk/Pk+R     Xk=Xk+gain(Zk-Xk)   Pk=(1-Kk)Pk
        
        let RSSI_p = average( X : RSSI, n : n)
        let Dist = find_distance( rssi_p : RSSI_p, rssi_c : -59)
        let R = 0.5 // the error of Xk
        var Zk : Double
        var gain : Double
        
        Xk = A*Xk
        Pk = A*Pk + Q
        Zk = Dist
        gain = (H*Pk)/(H*H*Pk + R)
        Xk += gain*(Zk - H*Xk)
        Pk = (1 - gain*H)*Pk
    
        return Xk
    }
    
    ////////////////////////////////////////////////////////////////
    
    func mean(X : [Double], Y : [Double]) -> (Double,Double){
        
        // m0 = A+B/2 , m1 = B+C/2 , m2 = A+C/2
        // A,m1 --> y-yA = (m1y - yA/m1x - xA)(x-xA) , B,m2 --> ...
        // y = y => x?
        
        let A = ((Y[2]+Y[0]/2) - Y[1]) / ((X[2]+X[0]/2) - X[1])
        let B = ((Y[1]+Y[2]/2) - Y[0]) / ((X[1]+X[2]/2) - X[0])
        let x = (A - B)*(A * X[1] - B * X[0])
        let y = A*(x - X[1]) + Y[1]
        
        return (x,y)
    }
    
    ////////////////////////////////////////////////////////////////
    
    func triangulation( x : [Double],
                        y : [Double],
                        d : [Double]) -> (Double, Double) {
        
        var a, dx, dy, D, h, rx, ry : Double
        var Xh, Yh : Double
        var xi, yi : Double
        
        var xarray : [Double] = [0,0,0,0]
        var yarray : [Double] = [0,0,0,0]
        
//        for i in 0...2 {
//
//            dx = x[(i+1)%3] - x[i]
//            dy = y[(i+1)%3] - y[i]
//            D = sqrt(dy*dy + dx*dx)
//
////            guard D < (d[i] + d[(i+1)%3]) else{
////                /* no solution. circles do not intersect. */
////                return (0,0)
////            }
////            guard D > fabs(d[i] - d[(i+1)%3]) else {
////                /* no solution. one circle is contained in the other */
////                return (0,0)
////            }
//
//            let a1 = (d[i]*d[i] - d[(i+1)%3]*d[(i+1)%3] + D*D)
//            a = a1 / (2.0 * D)
//
//            /* Determine the coordinates of point 2. */
//            Xh = x[i] + (dx * a/D)
//            Yh = y[i] + (dy * a/D)
//
//            /* Determine the distance from point 2 to either of the
//             * intersection points.
//             */
//            h = sqrt(abs(a*a - d[i]*d[i]))
//
//            /* Now determine the offsets of the intersection points from
//             * point 2.
//             */
//            rx = -dy * (h/D)
//            ry = dx * (h/D)
//
//            /* Determine the absolute intersection points. */
//
//            if sqrt(pow(y[(i+2)%3] - (Xh - rx), 2) + pow(x[(i+2)%3] - (Yh - ry), 2)) <=
//                sqrt(pow(y[(i+2)%3] - (Xh + rx), 2) + pow(x[(i+2)%3] - (Yh + ry), 2)) {
//                xi = Xh - rx
//                yi = Yh - ry
//            }
//            else {
//                xi = Xh + rx
//                yi = Yh + ry
//            }
//
//            xarray[i] = xi
//            yarray[i] = yi
//        }
        dx = x[1] - x[0]
        dy = y[1] - y[0]
        D = sqrt(dy*dy + dx*dx)
        let a1 = (d[0]*d[0] - d[1]*d[1] + D*D)
        a = a1 / (2.0 * D)
        Xh = x[0] + (dx * a/D)
        Yh = y[0] + (dy * a/D)
        h = sqrt(abs(a*a - d[0]*d[0]))
        rx = -dy * (h/D)
        ry = dx * (h/D)
        if sqrt(pow(y[2] - (Xh - rx), 2) + pow(x[2] - (Yh - ry), 2)) <=
            sqrt(pow(y[2] - (Xh + rx), 2) + pow(x[2] - (Yh + ry), 2)) {
            xi = Xh - rx
            yi = Yh - ry
        }
        else {
            xi = Xh + rx
            yi = Yh + ry
        }
        
        xarray[0] = xi
        yarray[0] = yi
        print("h is\(h)")
        print("Ah is \(a)")
        print("Xh is \(Xh)")
        print("Yh is \(Yh)")
        print("xi is \(xi)")
        print("yi is \(yi)")
        ////////////////////////
        dx = x[2] - x[1]
        dy = y[2] - y[1]
        D = sqrt(dy*dy + dx*dx)
        let a2 = (d[1]*d[1] - d[2]*d[2] + D*D)
        a = a2 / (2.0 * D)
        Xh = x[1] + (dx * a/D)
        Yh = y[1] + (dy * a/D)
        h = sqrt(abs(a*a - d[1]*d[1]))
        rx = -dy * (h/D)//////////////////manfi dasht
        ry = dx * (h/D)
        if sqrt(pow(y[0] - (Xh - rx), 2) + pow(x[0] - (Yh - ry), 2)) <=
            sqrt(pow(y[0] - (Xh + rx), 2) + pow(x[0] - (Yh + ry), 2)) {
            xi = Xh - rx
            yi = Yh - ry
        }
        else {
            xi = Xh + rx
            yi = Yh + ry
        }
        
        xarray[1] = xi
        yarray[1] = yi
        print("h is\(h)")
        print("Ah is \(a)")
        print("Xh is \(Xh)")
        print("Yh is \(Yh)")
        print("xi is \(xi)")
        print("yi is \(yi)")
        ////////////////////////////
        dx = x[0] - x[2]
        dy = y[0] - y[2]
        print(dy)
        D = sqrt(dy*dy + dx*dx)
        let a3 = (d[2]*d[2] - d[0]*d[0] + D*D)
        a = a3 / (2.0 * D)
        Xh = x[2] + (dx * a/D)
        Yh = y[2] + (dy * a/D)
        h = sqrt(abs(a*a - d[2]*d[2]))
        rx = -dy * (h/D)
        ry = dx * (h/D)
        if sqrt(pow(y[1] - (Xh - rx), 2) + pow(x[1] - (Yh - ry), 2)) <=
            sqrt(pow(y[1] - (Xh + rx), 2) + pow(x[1] - (Yh + ry), 2)) {
            xi = Xh - rx
            yi = Yh - ry
        }
        else {
            xi = Xh + rx
            yi = Yh + ry
        }
        
        xarray[2] = xi
        yarray[2] = yi
        print("h is\(h)")
        print("Ah is \(a)")
        print("Xh is \(Xh)")
        print("Yh is \(Yh)")
        print("xi is \(xi)")
        print("yi is \(yi)")

        return mean(X : xarray, Y : yarray)
    }
    
    ////////////////////////////////////////////////////////////////
    
    func main() -> (Int,Int) {

        var ave : [Double] = [0 , 0 , 0 , 0]
        var varians : Double
        var Distance : [Double] = [0,0,0,0]
        var count : [Int] = [10,10,10,10]
        var max : Int
        var maxIndex = 0
        var xPos = [Double]()
        var yPos = [Double]()
        var Xout = Double()
        var Yout = Double()

        /////////////////////////////////////

            max = rssi[2].first!
            for i in 0...3{
                if rssi[i].count > 0{
                if (max < rssi[i].first!){
                    max = rssi[i].first!
                    maxIndex = i
                }
                }
            }

            for i in 0...3 {
//                if i != maxIndex {
                    if rssi[i].count > 0{
//                        print(rssi[1])
                    ave[i] = average(X : rssi[i], n : count[i])
                    varians = std(X : rssi[i], n : count[i])
                    for j in 0...9{
                        if Double(rssi[i][j]) < (ave[i] - 2*varians){
                            rssi[i].remove(at: j)
                            count[i] -= 1
                            print(count[i])
                            }
                        }
                    
                    //------------------------------------------------------------------------
                        print("i is :\(i) and count is \(count[i])")
                    let RSSI_p = average( X : rssi[i], n : count[i])
                        print("rssi is \(RSSI_p)")
                    Distance[i] = find_distance( rssi_p : RSSI_p, rssi_c : -59)
                        print(Distance[i])

                    // kalman_filter(RSSI: rssi[i], n: count[i])

                    //------------------------------------------------------------------------

                    if (i == 0){
                        xPos.append(0)
                        yPos.append(0)
                    }
                    if (i == 1){
                        xPos.append(10)
                        yPos.append(0)
                    }
                    if (i == 2){
                        xPos.append(0)
                        yPos.append(0)
                    }
                    if (i == 3){
                        xPos.append(5)
                        yPos.append(8)
                    }
                }
//            }
        }


        (Xout, Yout) = triangulation(x: xPos, y: yPos, d: Distance)
        flag = true
        return (Int(Xout), Int(Yout))
    }
    
    
        /////////////////////////////////////////////////////////////
}

