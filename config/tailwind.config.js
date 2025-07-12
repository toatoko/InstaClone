// tailwind.config.js
module.exports = {
    content: [
        "./app/views/**/*.{html.erb,html,slim,haml}",
        "./app/helpers/**/*.rb",
        "./app/javascript/**/*.js",
        "./app/assets/stylesheets/**/*.css",
    ],
    theme: {
        extend: {},
    },
    plugins: [
        require("daisyui"),
        require('@tailwindcss/forms'),
        require('@tailwindcss/typography'),
        require('@tailwindcss/aspect-ratio'),
        require('@tailwindcss/line-clamp'),
        require('tailwindcss-transitions'), // optional
    ],

}
