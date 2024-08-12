package main

import (
	"crypto/aes"
	"crypto/cipher"
	"encoding/base64"
	"encoding/hex"
	"encoding/json"
	"errors"
	"fmt"
	"io"
	"net/http"
	"os"
	"strings"

	"github.com/tidwall/gjson"
	"github.com/tidwall/sjson"
)

type Token struct {
	TokenType    string `json:"token_type"`
	AccessToken  string `json:"access_token"`
	RefreshToken string `json:"refresh_token"`
	ExpiresIn    int    `json:"expires_in"`
}

func decrypt_AES256_CBC_PKCS7(ciphertext, key, iv string) (string, error) {
	decoded_ciphertext, _ := base64.StdEncoding.DecodeString(ciphertext)
	ivBytes, _ := hex.DecodeString(iv)
	key = key[:32]
	key = key + strings.Repeat("\x00", 32-len(key))
	block, err := aes.NewCipher([]byte(key))
	if err != nil {
		return "", err
	}
	if len(decoded_ciphertext) < aes.BlockSize {
		return "", errors.New("ciphertext too short")
	}
	cbc := cipher.NewCBCDecrypter(block, ivBytes)
	cbc.CryptBlocks(decoded_ciphertext, decoded_ciphertext)
	var unpad = func(ciphertext []byte) ([]byte, error) {
		padding := ciphertext[len(ciphertext)-1]
		if int(padding) > len(ciphertext) {
			return nil, errors.New("padding is invalid")
		}
		for i := 0; i < int(padding); i++ {
			if ciphertext[len(ciphertext)-i-1] != padding {
				return nil, errors.New("padding is invalid")
			}
		}
		return ciphertext[:len(ciphertext)-int(padding)], nil
	}
	unpadded_data, err := unpad(decoded_ciphertext)
	if err != nil {
		return "", err
	}
	return string(unpadded_data), nil
}

func main() {
	http.HandleFunc("/oauth/alipan/token", func(w http.ResponseWriter, r *http.Request) {
		r.ParseForm()
		refresh_token := r.FormValue("refresh_token")
		if refresh_token == "" {
			var body map[string]interface{}
			err := json.NewDecoder(r.Body).Decode(&body)
			if err != nil {
				http.Error(w, err.Error(), http.StatusBadRequest)
				return
			}
			if val, ok := body["refresh_token"]; ok {
				refresh_token = val.(string)
			}
		}
		fmt.Println(refresh_token)
		reqBodyJson := `{"refresh_token": "` + refresh_token + `"}`

		resp, err := http.Post("http://api.extscreen.com/aliyundrive/v2/token", "application/json", strings.NewReader(reqBodyJson))
		if err != nil {
			http.Error(w, err.Error(), http.StatusBadRequest)
			return
		}
		defer resp.Body.Close()

		respBody, _ := io.ReadAll(resp.Body)
		if gjson.Get(string(respBody), "code").Int() == 200 {
			ciphertext := gjson.Get(string(respBody), "data.ciphertext").String()
			iv := gjson.Get(string(respBody), "data.iv").String()

			key := "^(i/x>>5(ebyhumz*i1wkpk^orIs^Na."

			token_data, _ := decrypt_AES256_CBC_PKCS7(ciphertext, key, iv)

			var token Token
			json.Unmarshal([]byte(token_data), &token)

			resultBody, _ := sjson.Set("", "token_type", token.TokenType)
			resultBody, _ = sjson.Set(resultBody, "access_token", token.AccessToken)
			resultBody, _ = sjson.Set(resultBody, "refresh_token", token.RefreshToken)
			resultBody, _ = sjson.Set(resultBody, "expires_in", token.ExpiresIn)

			json.NewEncoder(w).Encode(resultBody)

		} else {
			json.NewEncoder(w).Encode(string(respBody))
		}
	})

	fmt.Println("Running on 34278")
	err := http.ListenAndServe(":34278", nil)

	if err != nil {
		fmt.Println(err)
		os.Exit(1)
	}
}
