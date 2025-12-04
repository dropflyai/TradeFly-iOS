//
//  SupabaseConfig.swift
//  TradeFly AI
//
//  Configuration for Supabase connection
//

import Foundation

struct SupabaseConfig {
    // TODO: Replace with your actual Supabase credentials
    // Get these from: https://app.supabase.com/project/_/settings/api

    static let url = "https://nplgxhthjwwyywbnvxzt.supabase.co"
    static let anonKey = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im5wbGd4aHRoand3eXl3Ym52eHp0Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjQxOTIxNzEsImV4cCI6MjA3OTc2ODE3MX0.If32Moy6QhAHNXQfvbMLLfa0ssErIzV91qbeylJS8cg"

    // Backend API URL (Python FastAPI server)
    static let backendURL = "http://localhost:8000"

    // Example:
    // static let url = "https://abcdefghijklmnop.supabase.co"
    // static let anonKey = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..."
}
