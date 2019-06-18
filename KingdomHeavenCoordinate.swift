
import Foundation
import CoreLocation

class KingdomHeavenCoordinate {
    
    let a = 6378245.0
    let ee = 0.00669342162296594323
    let pi = Double.pi
    
    func isOutOfChina(coordinate: CLLocationCoordinate2D) -> Bool {
        if coordinate.longitude < 72.004 || coordinate.longitude > 137.8347 {
            return true
        }
        if coordinate.latitude < 0.8293 || coordinate.latitude > 55.8271 {
            return true
        }
        return false
    }
    
    
    func transformLat(x: Double, y: Double) -> Double {
        
        var ret = -100.0 + 2.0 * x + 3.0 * y + 0.2 * y * y + 0.1 * x * y + 0.2 * sqrt(x > 0 ? x:-x)
        ret += (20.0 * sin(6.0 * x * pi) + 20.0 * sin(2.0 * x * pi)) * 2.0 / 3.0
        ret += (20.0 * sin(y * pi) + 40.0 * sin(y / 3.0 * pi)) * 2.0 / 3.0
        ret += (160.0 * sin(y / 12.0 * pi) + 320 * sin(y * pi / 30.0)) * 2.0 / 3.0
        
        return ret
    }
    
    
    func transformLon(x: Double, y: Double) -> Double {
        var ret = 300.0 + x + 2.0 * y + 0.1 * x * x + 0.1 * x * y + 0.1 * sqrt(x > 0 ? x:-x)
        ret += (20.0 * sin(6.0 * x * pi) + 20.0 * sin(2.0 * x * pi)) * 2.0 / 3.0
        ret += (20.0 * sin(x * pi) + 40.0 * sin(x / 3.0 * pi)) * 2.0 / 3.0
        ret += (150.0 * sin(x / 12.0 * pi) + 300.0 * sin(x / 30.0 * pi)) * 2.0 / 3.0
        
        return ret
    }
    
    
    ///
    /// 标准坐标 -> 中国坐标
    ///
    func transformFromWGSToGCJ(wgLoc: CLLocationCoordinate2D) -> CLLocationCoordinate2D {
        if isOutOfChina(coordinate: wgLoc) { return wgLoc }
        
        var dLat = transformLat(x: wgLoc.longitude - 105.0, y: wgLoc.latitude - 35.0)
        var dLon = transformLon(x: wgLoc.longitude - 105.0, y: wgLoc.latitude - 35.0)
        let radLat = wgLoc.latitude / 180.0 * pi
        var magic = sin(radLat)
        magic = 1 - ee * magic * magic
        let sqrtMagic = sqrt(magic)
        dLat = (dLat * 180.0) / ((a * (1 - ee)) / (magic * sqrtMagic) * pi)
        dLon = (dLon * 180.0) / (a / sqrtMagic * cos(radLat) * pi)
        let latitude = wgLoc.latitude + dLat
        let longitude = wgLoc.longitude + dLon
    
        return CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }
    
    
    ///
    /// 中国坐标 -> 标准坐标
    ///
    func transformFromGCJToWGS(gcLoc: CLLocationCoordinate2D) -> CLLocationCoordinate2D {
        var wgLoc = gcLoc
        var currGcLoc: CLLocationCoordinate2D
        var dLoc = CLLocationCoordinate2D()
        while (true) {
            currGcLoc = transformFromWGSToGCJ(wgLoc: wgLoc)
            dLoc.latitude = gcLoc.latitude - currGcLoc.latitude
            dLoc.longitude = gcLoc.longitude - currGcLoc.longitude
            if (fabs(dLoc.latitude) < 1e-7 && fabs(dLoc.longitude) < 1e-7) {
                // 1e-7 ~ centimeter level accuracy
                // Result of experiment:
                //   Most of the time 2 iterations would be enough for an 1e-8 accuracy (milimeter level).
                //
                return wgLoc
            }
            wgLoc.latitude += dLoc.latitude
            wgLoc.longitude += dLoc.longitude
        }
    
        return wgLoc
    }
    
    
    ///
    ///  Transform GCJ-02 to BD-09
    ///
    func bd_encrypt(gcLoc: CLLocationCoordinate2D) -> CLLocationCoordinate2D {
        return CLLocationCoordinate2D(latitude: gcLoc.latitude + 0.006, longitude: gcLoc.longitude + 0.0065)
    }
    
    
    ///
    ///  Transform BD-09 to GCJ-02
    ///
    func bd_decrypt(bdLoc: CLLocationCoordinate2D) -> CLLocationCoordinate2D {
        return CLLocationCoordinate2D(latitude: bdLoc.latitude - 0.006, longitude: bdLoc.longitude - 0.0065)
    }
}




