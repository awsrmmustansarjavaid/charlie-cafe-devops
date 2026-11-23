# State bootstrap
Run once with a globally unique bucket name. This creates encrypted, versioned, private S3 state storage. Keep this stack separate from the application environment. Bucket has `prevent_destroy=true`.
