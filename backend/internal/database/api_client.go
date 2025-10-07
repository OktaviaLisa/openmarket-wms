package database

import (
	"bytes"
	"encoding/json"
	"fmt"
	"io"
	"net/http"
	"time"
)

type APIClient struct {
	BaseURL string
	Client  *http.Client
}

type QueryRequest struct {
	SQL string `json:"sql"`
}

type QueryResponse struct {
	Data  []map[string]interface{} `json:"data"`
	Count int                      `json:"count"`
}

var APIConn *APIClient

func ConnectAPI(baseURL string) {
	APIConn = &APIClient{
		BaseURL: baseURL,
		Client: &http.Client{
			Timeout: 30 * time.Second,
		},
	}
	fmt.Printf("API client connected to: %s\n", baseURL)
}

func (c *APIClient) ExecuteQuery(sql string) ([]map[string]interface{}, error) {
	reqBody := QueryRequest{SQL: sql}
	jsonData, err := json.Marshal(reqBody)
	if err != nil {
		return nil, fmt.Errorf("error marshaling request: %v", err)
	}

	resp, err := c.Client.Post(c.BaseURL+"/execute", "application/json", bytes.NewBuffer(jsonData))
	if err != nil {
		return nil, fmt.Errorf("error making request: %v", err)
	}
	defer resp.Body.Close()

	body, err := io.ReadAll(resp.Body)
	if err != nil {
		return nil, fmt.Errorf("error reading response: %v", err)
	}

	if resp.StatusCode != http.StatusOK {
		return nil, fmt.Errorf("API error: %s", string(body))
	}

	var response QueryResponse
	if err := json.Unmarshal(body, &response); err != nil {
		return nil, fmt.Errorf("error unmarshaling response: %v", err)
	}

	return response.Data, nil
}

func (c *APIClient) QueryTable(tableName string, limit int) ([]map[string]interface{}, error) {
	url := fmt.Sprintf("%s/query/%s?limit=%d", c.BaseURL, tableName, limit)
	resp, err := c.Client.Get(url)
	if err != nil {
		return nil, fmt.Errorf("error making request: %v", err)
	}
	defer resp.Body.Close()

	body, err := io.ReadAll(resp.Body)
	if err != nil {
		return nil, fmt.Errorf("error reading response: %v", err)
	}

	if resp.StatusCode != http.StatusOK {
		return nil, fmt.Errorf("API error: %s", string(body))
	}

	var response QueryResponse
	if err := json.Unmarshal(body, &response); err != nil {
		return nil, fmt.Errorf("error unmarshaling response: %v", err)
	}

	return response.Data, nil
}