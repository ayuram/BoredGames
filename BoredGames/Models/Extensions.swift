//
//  Extensions.swift
//  BoredGames
//
//  Created by Ayush Raman on 3/8/24.
//

import Foundation


extension Array {
    func randomSample(n: Int) -> [Element] {
        var result = [Element]()
        var mutableArray = self

        for _ in 0..<Swift.min(n, self.count) {
            let randomIndex = Int.random(in: 0..<mutableArray.count)
            result.append(mutableArray[randomIndex])
            mutableArray.remove(at: randomIndex)
        }

        return result
    }
}
