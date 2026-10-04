//
//  Supabase.swift
//  84Days
//
//  Created by Isaac Evans on 1/10/2026.
//
// Allows for SupaBase as a backend

import Foundation
import Supabase

let supabase = SupabaseClient(
    supabaseURL: URL(string: "https://jjvgoiliraunmkavhgvy.supabase.co")!,
    supabaseKey: "sb_publishable_tJuq8LFtKTEOrtUa7vfmkA_HeNXQm8D"
)
