# 1. Use Node 20 as required by Next.js 16+
FROM node:20-alpine

WORKDIR /app

# Argument for theme names (Build time)
ARG THEME_NAME="Generic Business"
# Persist the theme name for Runtime (so we can name the log file)
ENV RUNTIME_THEME_NAME=$THEME_NAME

# 2. Manually create package.json to ensure 'dev' script exists
RUN echo '{ \
  "name": "react2shell-lab", \
  "version": "0.1.0", \
  "private": true, \
  "scripts": { \
    "dev": "next dev", \
    "build": "next build", \
    "start": "next start" \
  } \
}' > package.json

# 3. Install specific vulnerable versions
RUN npm install next@16.0.6 react@19.2.0 react-dom@19.2.0 --save-exact --legacy-peer-deps

# 4. Setup the App Router directory
RUN mkdir -p app

# 5. Create the themed landing page 
# (Single quotes handle the echo, double quotes inside handle the string interpolation)
RUN echo 'export default function Page() { \
  return ( \
    <main style={{ fontFamily: "sans-serif", padding: "50px", background: "#0d1117", color: "#c9d1d9", minHeight: "100vh" }}> \
      <div style={{ border: "2px solid #ff4500", padding: "30px", borderRadius: "12px" }}> \
        <h1 style={{ color: "#ff4500" }}>'"${THEME_NAME}"' - Internal Portal</h1> \
        <p>Operational Environment for Cyber Kill Chain Demonstration.</p> \
        <hr style={{ borderColor: "#30363d" }} /> \
        <p><strong>Security Lab Info:</strong></p> \
        <ul> \
          <li>Framework: Next.js 16.0.6 (Vulnerable)</li> \
          <li>Core: React 19.2.0 (Vulnerable to React2Shell)</li> \
          <li>Logging: Centralized</li> \
        </ul> \
      </div> \
    </main> \
  ); \
}' > app/page.js

# 6. Create the layout (Single line to prevent Hydration Error)
RUN echo 'export default function RootLayout({ children }) {return (<html lang="en"><body>{children}</body></html>);}' > app/layout.js

EXPOSE 3000

# 7. Start command: Create logs dir (if missing) and pipe output to unique file
# We use 'tr' to replace spaces with underscores in the filename
CMD ["/bin/sh", "-c", "mkdir -p logs && npm run dev > logs/$(echo \"$RUNTIME_THEME_NAME\" | tr ' ' '_').log 2>&1"]
