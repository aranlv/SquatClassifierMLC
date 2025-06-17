//
//  SummaryView.swift
//  SquatClassifierMLC
//
//  Created by Patricia Putri Art Syani on 17/06/25.
//

import SwiftUI

struct SummaryView: View {
    var totalReps: Int = 0
    var goodForm: Int = 0
    var badForm: Int = 0

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()

            VStack(spacing: 20) {
                HStack {
                    Button(action: {
                        // Close action
                    }) {
                        Image(systemName: "xmark.circle.fill")
                            .resizable()
                            .frame(width: 40, height: 40)
                            .foregroundColor(Color(.systemGray))
                            .padding()
                    }
                    Spacer()
                }

                Text("Workout Result")
                    .font(.largeTitle)
                    .bold()
                    .foregroundColor(.white)
                    .padding(.bottom, 10)


                Spacer()

                

                // Total Reps Circle
                ZStack {
                    Circle()
                        .stroke(Color.gray.opacity(0.6), lineWidth: 12)
                        .frame(width: 160, height: 160)

                    Circle()
                        .stroke(Color(#colorLiteral(red: 0.8235, green: 0.9333, blue: 0.2196, alpha: 1)), lineWidth: 2)
                        .frame(width: 170, height: 170)

                    VStack {
                        Text("Total Reps")
                            .foregroundColor(.gray)
                            .font(.subheadline)
                        Text("\(totalReps)")
                            .font(.system(size: 40, weight: .bold))
                            .foregroundColor(.black)
                    }
                    .frame(width: 140, height: 140)
                    .background(Color.white)
                    .clipShape(Circle())
                }

                Text("Good Job!")
                    .font(.title2)
                    .bold()
                    .foregroundColor(Color(#colorLiteral(red: 0.8235, green: 0.9333, blue: 0.2196, alpha: 1))) // Lime green

                // Good Form / Bad Form Count
                HStack(spacing: 170) {
                    VStack(spacing: 4) {
                        Text("\(goodForm)")
                            .font(.title)
                            .fontWeight(.bold)
                            .foregroundColor(Color(#colorLiteral(red: 0.8235, green: 0.9333, blue: 0.2196, alpha: 1))) // Lime green
                        Text("Good Form")
                            .font(.subheadline)
                            .foregroundColor(.white)
                            .bold()
                    }
                    VStack(spacing: 4) {
                        Text("\(badForm)")
                            .font(.title)
                            .fontWeight(.bold)
                            .foregroundColor(.red)
                        Text("Bad Form")
                            .font(.subheadline)
                            .foregroundColor(.white)
                            .bold()
                    }
                }
                .padding()
                .cornerRadius(16)


                // Buttons
                HStack(spacing: 150) {
                    VStack {
                        Button(action: {
                            // Video replay action
                        }) {
                            Image("videoreplay")
                                .resizable()
                                .frame(width: 50, height: 50)
                                .foregroundColor(.white)
                                .background(Circle().stroke(Color(#colorLiteral(red: 0.8235, green: 0.9333, blue: 0.2196, alpha: 1)), lineWidth: 2))
                        }
                        Text("Video Replay")
                            .foregroundColor(.white)
                            .font(.subheadline)
                    }

                    VStack {
                        Button(action: {
                            // Share action
                        }) {
                            Image("share")
                                .resizable()
                                .frame(width: 50, height: 50)
                                .foregroundColor(.white)
                                .background(Circle().stroke(Color(#colorLiteral(red: 0.8235, green: 0.9333, blue: 0.2196, alpha: 1)), lineWidth: 2))
                        }
                        Text("Share Video")
                            .foregroundColor(.white)
                            .font(.subheadline)
                    }
                }

                Spacer()

                // Start Again Button
                Button(action: {
                    // Restart action
                }) {
                    Text("Start Again")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color(#colorLiteral(red: 0.8235, green: 0.9333, blue: 0.2196, alpha: 1)))
                        .foregroundColor(.black)
                        .cornerRadius(12)
                        .font(.headline)
                        .padding(.horizontal)
                }

                Spacer().frame(height: 20)
            }
        }
    }
}

#Preview {
    SummaryView()
}
