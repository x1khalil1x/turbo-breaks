import React from 'react'

export default function SportsTrackerPage() {
  // For now, redirect to the actual sports tracker app
  // Later this can be updated to import the sports tracker components directly
  return (
    <div className="min-h-screen flex items-center justify-center">
      <div className="text-center">
        <h1 className="text-3xl font-bold mb-4">Sports Tracker</h1>
        <p className="mb-6">Track sports events, games, and athletic activities with real-time updates</p>
        <div className="bg-yellow-100 border border-yellow-400 text-yellow-700 px-4 py-3 rounded">
          <p className="font-semibold">Integration in Progress</p>
          <p className="text-sm">This project is being integrated into the AMF Hub. The full application will be available here soon.</p>
        </div>
      </div>
    </div>
  )
} 