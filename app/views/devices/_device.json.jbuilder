json.extract! device, :id, :token, :platform, :created_at, :updated_at
json.url app_device_url(@app, device, format: :json)
