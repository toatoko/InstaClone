// tailwind.config.js

module.exports = {
    content: [
        './app/views/**/*.{html.erb,html,slim,haml}',
        './app/helpers/**/*.rb',
        './app/javascript/**/*.js',
        './app/assets/stylesheets/**/*.css'
    ],
    darkMode: 'class', // Enables dark mode via .dark class
    theme: {
        extend: {
            colors: {
                'instagram-black': '#000000',
                'instagram-dark': '#262626',
                'instagram-gray': '#8e8e8e',
            }
        },
    },
    plugins: [
        require("daisyui"),
        require('@tailwindcss/forms'),
        require('@tailwindcss/typography'),
        require('@tailwindcss/aspect-ratio'),
        require('@tailwindcss/line-clamp'),
        require('tailwindcss-transitions'), // optional, if installed
    ]
}
