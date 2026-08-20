//
//  PreviewData.swift
//  XCreds Mobile
//
//  Created by Steve Brokaw on 8/20/26.
//
import Foundation
import OIDCLite


extension OIDCLite.TokenResponse {
    private static let idToken = "eyJ0eXAiOiJKV1QiLCJhbGciOiJub25lIn0.eyJhdWQiOiI1NDg3YzRjZC05NDlhLTQwMmQtOWVlZS1hZThmYjY5NmI0MTUiLCJpc3MiOiJodHRwczovL3N0cy53aW5kb3dzLm5ldC9lNjRhMmI1ZC0zZWIxLTQzNmUtOWU4YS01MjFmMGM1Y2Q0ODkvIiwiaWF0IjoxNzg3MjMzNjEyLCJuYmYiOjE3ODcyMzM2MTIsImV4cCI6MTc4NzIzNzUxMiwiYW1yIjpbInB3ZCJdLCJmYW1pbHlfbmFtZSI6IlJ1YmJsZSIsImdpdmVuX25hbWUiOiJCYXJuZXkiLCJpcGFkZHIiOiIyNjA1OmE2MDE6YTBmMDoxZDAwOjM4OTU6OTc2NDoxZDk0OjRhYWEiLCJuYW1lIjoiYmFybmV5Iiwib2lkIjoiNjUwMDc1MTQtOWI2MS00NzZiLTkzMTUtMjY4MzIxYWZjYTllIiwicmgiOiIxLkFWa0FYU3RLNXJFLWJrT2VpbElmREZ6VWljM0VoMVNhbEMxQW51NnVqN2FXdEJVQUFPaFpBQS4iLCJzdWIiOiJ2MU5iSXJNcFd2NFg4T1dlUGpIcm9vb0pmYUtkMkZHNUZtNHFnbms0Y1NvIiwidGlkIjoiZTY0YTJiNWQtM2ViMS00MzZlLTllOGEtNTIxZjBjNWNkNDg5IiwidW5pcXVlX25hbWUiOiJiYXJuZXlAdHdvY2Fub2VzLmNvbSIsInVwbiI6ImJhcm5leUB0d29jYW5vZXMuY29tIiwidmVyIjoiMS4wIiwid2lkcyI6WyJiNzlmYmY0ZC0zZWY5LTQ2ODktODE0My03NmIxOTRlODU1MDkiXX0."
    private static let accessToken = "eyJ0eXAiOiJKV1QiLCJub25jZSI6IjIzRFFoMFVQY3NjS2lFdVpsdzA4N1o2RkZNVTVPMHR1Z2NQTTBjaGhDTXciLCJhbGciOiJSUzI1NiIsIng1dCI6ImZFdHFyaEtUMWJYQUdhZlNkUW9OMXZYVFJwSSIsImtpZCI6ImZFdHFyaEtUMWJYQUdhZlNkUW9OMXZYVFJwSSJ9.eyJhdWQiOiJodHRwczovL2dyYXBoLm1pY3Jvc29mdC5jb20iLCJpc3MiOiJodHRwczovL3N0cy53aW5kb3dzLm5ldC9lNjRhMmI1ZC0zZWIxLTQzNmUtOWU4YS01MjFmMGM1Y2Q0ODkvIiwiaWF0IjoxNzg3MjMzNjEyLCJuYmYiOjE3ODcyMzM2MTIsImV4cCI6MTc4NzIzODA1NiwiYWNjdCI6MCwiYWNyIjoiMSIsImFjcnMiOlsicGZkciJdLCJhaW8iOiJBVVFBdS84Y0FBQUFUb0pRQit5VnVMSHVJbWFjM3JNR1FDbHRGSVo2WHZyRFhQSEVpOHR1YjJDc0pFLzg4VzZqUFE2cWQ2SllqaXNBbFZzbU5JT3RSRjZRbE8yOEVySHBDZz09IiwiYW1yIjpbInB3ZCJdLCJhcHBfZGlzcGxheW5hbWUiOiJ4Y3JlZHMiLCJhcHBpZCI6IjU0ODdjNGNkLTk0OWEtNDAyZC05ZWVlLWFlOGZiNjk2YjQxNSIsImFwcGlkYWNyIjoiMSIsImZhbWlseV9uYW1lIjoiUnViYmxlIiwiZ2l2ZW5fbmFtZSI6IkJhcm5leSIsImlkdHlwIjoidXNlciIsImlwYWRkciI6IjI2MDU6YTYwMTphMGYwOjFkMDA6Mzg5NTo5NzY0OjFkOTQ6NGFhYSIsIm5hbWUiOiJiYXJuZXkiLCJvaWQiOiI2NTAwNzUxNC05YjYxLTQ3NmItOTMxNS0yNjgzMjFhZmNhOWUiLCJwbGF0ZiI6IjE0IiwicHVpZCI6IjEwMDMyMDAzMjc0NjZFOTEiLCJyaCI6IjEuQVZrQVhTdEs1ckUtYmtPZWlsSWZERnpVaVFNQUFBQUFBQUFBd0FBQUFBQUFBQUFBQU9oWkFBLiIsInNjcCI6IlVzZXIuUmVhZCIsInNpZCI6IjAwN2QyNzJhLTBjNzktN2YyZi04ZWMwLTViZDMwZGFhYjMzMSIsInN1YiI6IjZzWVNGZTNfaEI0NGFjTjlsQzJrLS1OTkRPQWYzaXcxSjgyQ3Byc0ZVc00iLCJ0ZW5hbnRfcmVnaW9uX3Njb3BlIjoiTkEiLCJ0aWQiOiJlNjRhMmI1ZC0zZWIxLTQzNmUtOWU4YS01MjFmMGM1Y2Q0ODkiLCJ1bmlxdWVfbmFtZSI6ImJhcm5leUB0d29jYW5vZXMuY29tIiwidXBuIjoiYmFybmV5QHR3b2Nhbm9lcy5jb20iLCJ1dGkiOiJJZ19sd2NDSThrbWdKWnNJM3NkZkFBIiwidmVyIjoiMS4wIiwid2lkcyI6WyJiNzlmYmY0ZC0zZWY5LTQ2ODktODE0My03NmIxOTRlODU1MDkiXSwieG1zX2FjZCI6MTY1NDI3Mjk5MSwieG1zX2FjdF9mY3QiOiIzIDkiLCJ4bXNfZnRkIjoiQXNTZW84cFY1YlY0Ym5KY2xMS0NiT2xmQVJVR1RpbHJJcUpnOWN2MmFPVUJkWE4zWlhOME15MWtjMjF6IiwieG1zX2lkcmVsIjoiMSAxNCIsInhtc19wZnRleHAiOjE3ODczMjQ0NTYsInhtc19zdWJfZmN0IjoiMyAyIiwieG1zX3RjZHQiOjE1OTI5NDk0OTQsInhtc190bnRfZmN0IjoiMyAxOCJ9.NiDCX5ZwvSoSGGGkXNBKZ5JewjKUW-V-_cF9wfQ7YcuP_9pMdJ0dUTzPMq0c4W_TZpWjrCZ64ofgiILR0D9IdrrWzHm1dPnDaTLu_oebzurJeV5Y5UtIelB6K13M8uLqS1ZRWlVkgZUphZp8kdUFmdsbUHviamON89h3sHHKQXRISUQrAc45S-bRH67zU8CckIwP2B3M1osxtJbi_OAz9vB4-H_YyYDSyeHZ5tYVOsfrHW2mmLbKTkIpU3g5_RCh5EOFAwgzJ6Qz8sm4FgDRTUbNrZMO9RJP3CjFkqvQlQeJAI99d2-CsfmAi9omJ-zAHXriiR4Z7NE-tFIn8zIC8A"
    private static let refreshToken = "1.AVkAXStK5rE-bkOeilIfDFzUic3Eh1SalC1Anu6uj7aWtBUAAOhZAA.BQABAwEAAAADAOz_BQD0_0V2b1N0c0FydGlmYWN0cwIAAAAAAOLIiOZZ1T-inNODUwXFeDdVAWSqnywc39c26cYUE-Q5MOghs9_KLr9Qk0TBjfHNseD4kTnMY_-UZSZ7IAHwfAz4D1QdSlejVmMBupWAA3Jpy02z_h-s0tfj9hAmg7eZ9Eq-hMyr_uyj9jr5lih9VQG8FpeppbSrzVQTlObZBi8wbNZ92cCY69i8x4tBdDRBBpYAJ7Bu0f7GoQEyt2yvy0rTsX6jKFDvPYzNBd6feWOWArFTVQ0k6YOhkOQI9RrxOn_KemuvJ1grmaKhfXqA5K8NGrBVlpWEJ6AgWqAFQmF-jbq7t1wAKwig4V_4jSYWXrnMdkcuf9RnkZZWB1LJkpznfBNY6W4NhlwXSIYWJLOYQQSA0V7XgAlb1cDh3S0JYZDvQcbn5lqnQojeQfynwFTS1tqd4tj3wjkd7McBKgy4nrQw9cfZnq35YKWoWdnCfUF0CmhLcI87Rx3EpUHchyxJt6E2RTD_OzCqw-mu2ugyQxeDJVZP5N4Fo2ylilvKe0IkRHVXqAFDUbiYPHPsR0augwppgr8EicC1EEweDvJ9KFoGfAAsjmOXhoqreEk8ZyK04E6yYllhtxYC3c46suyqsLs00Eb4e74Y7C1TsQHS1Vgc_UWKfRPmLvuMVuHusCTx-G_d22xWfq9KvkHAMEF30v_CYp87veZpJDGPF24qS0A79NSaL2IYD1CxdYiZrTg848DX3_tMpHWwUHsIMAseFjzeVbTR7a-iBnr73_TXziGHdyLtfwCqZE0bgoiZwnrERIHHdfnKpcwKN_4FBHnO5MQE15pkED9pW5FhKkQqUNrf5HGlgz4BUNkjq4_zQuk5tM_7DHieQOIQ16OnPw5ALpMaKcGg6sWc1xogQShemllC-GXMvZSHj0R7W-FfZXQq01xdSKy1trjdJ4M39aUYlL9iagcIyinfY9KQWoqEiDWmWvnfCPzh_xKtNw-pJHtp9jiF1hWKAMWk5Y-MXU49Nx9604G5tG3C8uKOVDt3Igtdrly5iafPnxucnaNsaNDsJdq3A8ESUarBte7C6mlyqAtPIE7syUILUsb1pNEUKQNDGvR1RQgdfphyGqPgyCiUtbhKhAZLSjmafGdqcQhNnRw9590WbXxtmEXpq1KWRW7DkxUoYGRVRbj5sJ2fCt88lj3fE4RNTaJ1SRzKOybTXuAws-JS7XvczuEiyqZVFjAJgpX6hUHGe5Isxm8m0w9N99ldhriP8vt4gwqmh-zxICrjaz0haDOiuD6gtyQe"
    private static let expiresIn = 4143
    private static let tokenType = "Bearer"
    private static let scope = "User.Read"
    static var preview: OIDCLite.TokenResponse {
        OIDCLite.TokenResponse(accessToken: accessToken,
                               idToken: idToken,
                               refreshToken: refreshToken,
                               expiresIn: expiresIn,
                               tokenType: "Bearer",
                               scope: "User.Read",
                               jsonDict: [
                                "ext_expires_in": expiresIn,
                                "expires_in": expiresIn,
                                "id_token": idToken,
                                "not_before": 1787233612,
                                "expires_on": 1787238056,
                                "refresh_token": refreshToken
                               ])
    }
}
extension IDToken {
    static var preview: IDToken {
        IDToken(
            iss: "ISS String",
            sub: "Sub String",
            aud: .array(["aud", "array"]),
            iat: 1,
            exp: 2,
            email: "email",
            unique_name: "Unique Name",
            given_name: "Given Name",
            family_name: "Family Name",
            name: "Name"
        )
    }
}
