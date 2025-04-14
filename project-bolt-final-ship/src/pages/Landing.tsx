import React from 'react';
import { Link } from 'react-router-dom';
import { Cloud, Heart, Brain, Sparkles, ArrowRight, CheckCircle } from 'lucide-react';

export default function Landing() {
  return (
    <div className="min-h-screen bg-gradient-to-b from-blue-50 to-white overflow-hidden">
      <nav className="fixed w-full bg-white/80 backdrop-blur-sm z-50">
        <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
          <div className="flex justify-between h-16 items-center">
            <div className="flex items-center">
              <Cloud className="h-8 w-8 text-cloud-blue" />
              <span className="ml-2 text-xl font-bold text-gray-900">MoodBuddy</span>
            </div>
            <div className="flex items-center space-x-4">
              <Link to="/login" className="text-gray-600 hover:text-gray-900">Log in</Link>
              <Link to="/signup" className="px-4 py-2 bg-coral-orange text-white rounded-lg hover:bg-opacity-90">
                Sign up free
              </Link>
            </div>
          </div>
        </div>
      </nav>

      <main>
        {/* Hero Section */}
        <div className="pt-32 pb-20 px-4">
          <div className="max-w-4xl mx-auto text-center">
            <h1 className="text-5xl sm:text-6xl font-bold bg-gradient-to-r from-cloud-blue to-coral-orange bg-clip-text text-transparent mb-6">
              Supporting Student Emotional Wellness
            </h1>
            <p className="text-xl text-gray-600 mb-8 max-w-2xl mx-auto">
              A safe space for students to track their emotional well-being, connect with support systems, and develop healthy coping strategies.
            </p>
            <div className="flex flex-col sm:flex-row items-center justify-center gap-4">
              <Link
                to="/signup"
                className="px-8 py-4 bg-coral-orange text-white rounded-lg hover:bg-opacity-90 transition-all transform hover:scale-105 flex items-center justify-center w-full sm:w-auto"
              >
                Join the Beta <ArrowRight className="ml-2 h-5 w-5" />
              </Link>
              <a
                href="#features"
                className="px-8 py-4 border border-gray-200 rounded-lg hover:border-coral-orange text-gray-600 hover:text-coral-orange transition-all flex items-center justify-center w-full sm:w-auto"
              >
                Learn More
              </a>
            </div>
          </div>
        </div>

        {/* Features Section */}
        <div id="features" className="py-20 bg-white">
          <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
            <div className="text-center mb-16">
              <h2 className="text-3xl font-bold text-gray-900 mb-4">Features Built for Students</h2>
              <p className="text-gray-600 max-w-2xl mx-auto">
                Tools and features designed to support student emotional well-being and academic success.
              </p>
            </div>
            
            <div className="grid md:grid-cols-3 gap-8">
              <div className="bg-gradient-to-br from-blue-50 to-white p-8 rounded-2xl shadow-sm border border-blue-100">
                <div className="bg-blue-100 w-12 h-12 rounded-lg flex items-center justify-center mb-6">
                  <Brain className="h-6 w-6 text-cloud-blue" />
                </div>
                <h3 className="text-xl font-semibold mb-4">Smart Mood Tracking</h3>
                <p className="text-gray-600">Track your emotional journey with AI-powered insights and personalized recommendations.</p>
              </div>
              
              <div className="bg-gradient-to-br from-red-50 to-white p-8 rounded-2xl shadow-sm border border-red-100">
                <div className="bg-red-100 w-12 h-12 rounded-lg flex items-center justify-center mb-6">
                  <Heart className="h-6 w-6 text-coral-orange" />
                </div>
                <h3 className="text-xl font-semibold mb-4">Expert Support</h3>
                <p className="text-gray-600">Connect with trained professionals and get the support you need, when you need it.</p>
              </div>
              
              <div className="bg-gradient-to-br from-green-50 to-white p-8 rounded-2xl shadow-sm border border-green-100">
                <div className="bg-green-100 w-12 h-12 rounded-lg flex items-center justify-center mb-6">
                  <Sparkles className="h-6 w-6 text-calm-green" />
                </div>
                <h3 className="text-xl font-semibold mb-4">Achievement System</h3>
                <p className="text-gray-600">Stay motivated with fun challenges, rewards, and track your progress over time.</p>
              </div>
            </div>
          </div>
        </div>

        {/* Social Proof */}
        <div className="py-20 bg-gray-50">
          <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
            <div className="text-center mb-16">
              <h2 className="text-3xl font-bold text-gray-900 mb-4">Built for Education</h2>
              <p className="text-gray-600">Designed with input from educators and mental health professionals</p>
            </div>
            
            <div className="grid sm:grid-cols-2 lg:grid-cols-4 gap-6">
              {[
                { stat: 'Private', label: 'Data Protection' },
                { stat: '24/7', label: 'Availability' },
                { stat: 'Free', label: 'During Beta' },
                { stat: 'Secure', label: 'Platform' }
              ].map((item, index) => (
                <div key={index} className="bg-white p-6 rounded-xl text-center">
                  <div className="text-3xl font-bold text-coral-orange mb-2">{item.stat}</div>
                  <div className="text-gray-600">{item.label}</div>
                </div>
              ))}
            </div>
          </div>
        </div>

        {/* CTA Section */}
        <div className="py-20">
          <div className="max-w-4xl mx-auto text-center px-4">
            <h2 className="text-3xl font-bold text-gray-900 mb-6">Join Our Beta Program</h2>
            <p className="text-xl text-gray-600 mb-8">
              Be among the first to try MoodBuddy and help shape the future of student emotional support.
            </p>
            <Link
              to="/signup"
              className="inline-flex items-center px-8 py-4 bg-coral-orange text-white rounded-lg hover:bg-opacity-90 transition-all transform hover:scale-105"
            >
              Sign Up for Beta <CheckCircle className="ml-2 h-5 w-5" />
            </Link>
          </div>
        </div>
      </main>
    </div>
  );
}