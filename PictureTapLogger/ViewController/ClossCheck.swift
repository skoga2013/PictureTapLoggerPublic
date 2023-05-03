//
//  ClossCheck.swift
//  RouteMaker
//
//  Created by 古賀真一郎 on 2023/02/21.
//

import Foundation
class ClossCheck {
    
    //点間距離
    func distance_vertex(p1: CGPoint, p2: CGPoint)->Double {
        return sqrt((p2.x - p1.x) * (p2.x - p1.x) + (p2.y - p1.y) * (p2.y - p1.y))
    }
    
    //ベクトル外積
    func cross_vector(vl:CGPoint, vr:CGPoint) -> Double {
        return vl.x * vr.y - vl.y * vr.x
        
    }
    
    //単位ベクトル生成
    func ceate_unit_vector(v:CGPoint) ->CGPoint {
        let len = sqrt((v.x * v.x) + (v.y * v.y)) //ベクトル長さ
        
        var ret = CGPoint()
        ret.x = v.x / len
        ret.y = v.y / len
        
        return ret
    }
    //ベクトル内積
    func dot_product(vl:CGPoint, vr:CGPoint) ->Double {
        return vl.x * vr.x + vl.y * vr.y
    }
    //点Pと直線ABから線上最近点を求める
    func NearPosOnLine(P:CGPoint, A:CGPoint, B:CGPoint) -> (ret:Int, dist:Double, point:CGPoint) {
        
        var AB = CGPoint() //ベクトルAB
        var AP = CGPoint() //ベクトルAP
        
        AB.x = B.x - A.x
        AB.y = B.y - A.y
        AP.x = P.x - A.x
        AP.y = P.y - A.y
        
//        if AB == nil{
//            return (-1, 0.0, CGPoint.zero)
//        }
        //ABの単位ベクトルを計算
        let nAB:CGPoint = ceate_unit_vector(v:AB)
        
        //Aから線上最近点までの距離（ABベクトルの後ろにあるときはマイナス値）
        let dist_AX = dot_product(vl:nAB, vr:AP)
        
        //線上最近点
        var point = CGPoint()
        point.x = A.x + (nAB.x * dist_AX)
        point.y = A.y + (nAB.y * dist_AX)
        
        //線分ABの間であるか確認
        if inner(n1:A.x, n2:B.x, n3:point.x) && inner(n1:A.y, n2:B.y, n3:point.y) {
            return (0, distance_vertex(p1:P, p2:point), point)
        } else {
            return (-1, 0.0, CGPoint.zero)
            
        }
        
    }
    
    
    //点Pと線(AB)の距離
    func XDistance_DotAndLine(P:CGPoint, A:CGPoint, B:CGPoint) -> Double{
        var AB = CGPoint()
        var AP = CGPoint()
        
        AB.x = B.x - A.x
        AB.y = B.y - A.y
        AP.x = P.x - A.x
        AP.y = P.y - A.y
        
        //ベクトルAB、APの外積の絶対値が平行四辺形Dの面積になる
        let D = abs(cross_vector(vl:AB, vr:AP))
        
        let L = distance_vertex(p1:A, p2:B)  //AB間の距離
        
        let H = D / L
        return H
        
    }
    
    //点Pと線(AB)の距離
    func Distance_DotAndLine(P:CGPoint, A:CGPoint, B:CGPoint) ->Double{
        var aa = 0.0
        var bb = 0.0
        var cc = 0.0  // aax + bby + cc = 0
        var root = 0.0
        var dist = 0.0 //求める距離
        
        aa = A.y - B.y
        bb = B.x - A.x
        cc = (-bb * A.y) + (-aa * A.x)
        root = sqrt(aa * aa + bb * bb)
        
        if root == 0.0 {
            return -1.0 // 求められない場合は負の値を返す */
        }
        
        dist = ((aa * P.x) + (bb * P.y) + cc) / root
        
        if dist < 0.0 {
            dist = -dist
        }
        
        return dist
        
    }
    //直線の交点を返す。(0, CGPoint) データが無いルートとの交わりは(-1, CGPint.zero)
    func clossLineCheck(p1:CGPoint, p2:CGPoint, p3:CGPoint, p4:CGPoint) -> (ret:Int, point:CGPoint) {
        return clossLine(p1:p1, p2:p2, p3:p3, p4:p4)
    }
    
    //直線の交点を返す。(1, CGPoint) 交わらないときは(-1, CGPoint.zero)を返す
    func clossLine(p1:CGPoint, p2:CGPoint, p3:CGPoint, p4:CGPoint) -> (ret:Int, point:CGPoint) {
        var x1 = 0.0
        var x2 = 0.0
        var x3 = 0.0
        var x4 = 0.0
        
        var y1 = 0.0
        var y2 = 0.0
        var y3 = 0.0
        var y4 = 0.0
        
        //x1<x2
        if p1.x < p2.x {
            x1 = p1.x
            x2 = p2.x
            y1 = p1.y
            y2 = p2.y
        } else {
            x1 = p2.x
            x2 = p1.x
            y1 = p2.y
            y2 = p1.y
        }
        //x3<x4
        if p3.x < p4.x {
            x3 = p3.x
            x4 = p4.x
            y3 = p3.y
            y4 = p4.y
        } else {
            x3 = p4.x
            x4 = p3.x
            y3 = p4.y
            y4 = p3.y
            
        }
        
        if x1 == x2 {
            //縦線
            if y3 == y4 {
                //１直行
                if inner(n1:x3, n2:x4, n3:x1) && inner(n1:y1, n2:y2, n3:y3) {
                    return (0,CGPoint(x:x1, y:y3))
                } else {
                    return (-1, CGPoint.zero)
                }
            } else if x3 == x4 {
                //２縦平行
                if x1 == x3 {
                    if inner(n1:y1, n2:y2, n3:y3) {
                        return (0, CGPoint(x:x3, y:y3))
                    }else if inner(n1:y1, n2:y2, n3:y4) {
                        return (0, CGPoint(x:x4, y:y4))
                    } else {
                        return (-1, CGPoint.zero)
                    }
                } else {
                    return (-1, CGPoint.zero)
                }
            } else {
                //３縦線との交わり
                let a = (y4 - y3) / (x4 - x3)
                let b = y3 - a * x3
                let x = x1
                let y = a * x + b
                if inner(n1:x1, n2:x2, n3:x) && inner(n1:y1, n2:y2, n3:y) && inner(n1:x3, n2:x4, n3:x) && inner(n1:y3, n2:y4, n3:y) {
                    
                    
                    return (0, CGPoint(x:x, y:y))
                } else {
                    return (-1, CGPoint.zero)
                }
            }
        }
        
        if x3 == x4 {
            //縦線
            if y1 == y2 {
                //４直行
                if inner(n1:x1, n2:x2, n3:x3) && inner(n1:y3, n2:y4, n3:y1) {
                    return (0, CGPoint(x:x3, y:y1))
                } else {
                    return (-1, CGPoint.zero)
                }
            } else {
                //５縦との交わり
                let a = (y2 - y1) / (x2 - x1)
                let b = y1 - a * x1
                let x = x3
                let y = a * x + b
                if inner(n1:x1, n2:x2, n3:x) && inner(n1:y1, n2:y2, n3:y) && inner(n1:x3, n2:x4, n3:x) && inner(n1:y3, n2:y4, n3:y) {
                    return (0, CGPoint(x:x, y:y))
                } else {
                    return (-1, CGPoint.zero)
                }
            }
        }
        
        if y1 == y2 && y3 == y4 {
            //６水平平行
            if y1 == y3 {
                
                if inner(n1:x1, n2:x2, n3:x3) {
                    return (0, CGPoint(x:x3, y:y3))
                } else if inner(n1:x1, n2:x2, n3:x4) {
                    return (0, CGPoint(x:x4, y:y4))
                } else {
                    return (-1, CGPoint.zero)
                }
            } else {
                return (-1, CGPoint.zero)
            }
        }
        
        
        if y1 == y2 {
            //７片方が水平
            
           // let a1 = 0.0
            let a3 = (y4 - y3) / (x4 - x3)
            let x = (-y1 - a3 * x3 + y3) / (-a3)
            let y = y1
            
            if inner(n1:x1, n2:x2, n3:x) && inner(n1:y1, n2:y2, n3:y) && inner(n1:x3, n2:x4, n3:x) && inner(n1:y3, n2:y4, n3:y) {
                return (0, CGPoint(x:x, y:y))
            } else {
                return (-1, CGPoint.zero)
            }
        }
        if y3 == y4 {
            //７片方が水平
            let a1 = (y2 - y1) / (x2 - x1)
            //let a3 = 0.0
            let x = (a1 * x1 - y1 + y3) / (a1)
            let y = y3
            
            if inner(n1:x1, n2:x2, n3:x) && inner(n1:y1, n2:y2, n3:y) && inner(n1:x3, n2:x4, n3:x) && inner(n1:y3, n2:y4, n3:y) {
                return (0, CGPoint(x:x, y:y))
            } else {
                return (-1, CGPoint.zero)
            }
        }
        //８普通の交わり
        if true {
            let a1 = (y2 - y1) / (x2 - x1)
            let a3 = (y4 - y3) / (x4 - x3)
            let x = (a1 * x1 - y1 - a3 * x3 + y3) / (a1 - a3)
            let y = (y2 - y1) / (x2 - x1) * (x - x1) + y1
            
            if x == 0.0 && y == 0.0 {
                print(" ")
            }
            
            if inner(n1:x1, n2:x2, n3:x) && inner(n1:y1, n2:y2, n3:y) && inner(n1:x3, n2:x4, n3:x) && inner(n1:y3, n2:y4, n3:y) {
                return (0, CGPoint(x:x, y:y))
            } else {
                return (-1, CGPoint.zero)
            }
        }
    }
    
    
    func inner(n1:Double, n2:Double, n3:Double) -> Bool {
        //n1 < n3 < n2 ならtrueを返す
        if n1 == n2 {
            if n1 == n3 {
                return true
            }
        } else if n1 < n2 {
            if n1 <= n3 && n3 <= n2 {
                return true
            }
        } else {
            if n1 >= n3 && n3 >= n2 {
                return true
            }
        }
        
        return false
    }
    
    //座標 p1,p2 を通る直線と座標 p3,p4 を結ぶ線分が交差しているかを調べる
    func intersect(p1:CGPoint, p2:CGPoint, p3:CGPoint, p4:CGPoint) -> Bool {
        
        let x1 = p1.x
        let x2 = p2.x
        let x3 = p3.x
        let x4 = p4.x
        
        let y1 = p1.y
        let y2 = p2.y
        let y3 = p3.y
        let y4 = p4.y
        
        if x1 == x2 {
            if y3 == y4 {
                //直交
                if x3 < x4 {
                    if x3 <= x1 && x4 >= x1 {
                        if y1 < y2 {
                            if y1 <= y3 && y2 >= y3 {
                                return true
                            } else {
                                if y1 >= y3 && y2 <= y3 {
                                    return true
                                }
                            }
                        }
                    } else {
                        if x3 >= x1 && x4 <= x1 {
                            if y1 < y2 {
                                if y1 <= y3 && y2 >= y3 {
                                    return true
                                }
                            } else {
                                if y1 >= y3 && y2 <= y3 {
                                    return true
                                }
                            }
                        }
                    }
                } else {
                    if x3 == x4 {
                        //縦平行
                        if x1 == x3 {
                            return true
                        }
                    } else {
                        let a3 = (y4 - y3) / (x4 - x3)
                        //let x = x1
                        let y = a3 * x1 + (y3 - a3 * x3)
                        if y1 < y2 {
                            if y1 <= y && y2 >= y {
                                return true
                            }
                        } else {
                            if y1 >= y && y2 <= y {
                                return true
                            }
                        }
                    }
                }
            }
        } else {
            if x3 == x4 {
                if y1 == y2 {
                    //直行
                    if x1 < x2 {
                        if x1 <= x3 && x2 >= x4 {
                            if y3 < y4 {
                                if y3 <= y4 && y4 >= y1 {
                                    return true
                                }
                            } else {
                                if y3 >= y1 && y4 <= y1 {
                                    return true
                                }
                            }
                        }
                    } else {
                        if x1 >= x3 && x2 <= x3 {
                            if y3 < y4 {
                                if y3 <= y1 && y4 >= y1 {
                                    return true
                                }
                            } else {
                                if y3 >= y1 && y3 <= y1 {
                                    return true
                                }
                            }
                        }
                    }
                } else {
                    let a3 = (y2 - y1) / (x2 - x1)
                    //let x = x3
                    let y = a3 * x3 + (y1 - a3 * x1)
                    if y3 < y4 {
                        if y3 <= y && y4 >= y {
                            return true
                        }
                    } else {
                        if y3 >= y && y4 <= y {
                            return true
                        }
                    }
                }
            } else {
                let r = ((y4 - y3) * (x3 - x1) - (x4 - x3) * (y3 - y1)) / ((x2 - x1) * (y4 - y3) - (y2 - y1) * (x4 - x3))
                let s = ((y2 - y1) * (x3 - x1) - (x2 - x1) * (y3 - y1)) / ((x2 - x1) * (y4 - y3) - (y2 - y1) * (x4 - x3))
                
                if r >= 0 && r <= 1 && s >= 0 && s <= 1 {
                    return true
                } else {
                    return false
                }
            }
            return false
        }
        return false
    }
}
