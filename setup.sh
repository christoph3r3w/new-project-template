#!/bin/bash

# Colors
GREEN='\033[0;32m'
BLUE='\033[1;34m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
BOLD='\033[1m'
RESET='\033[0m'

echo -e "${BLUE}${BOLD}🛠 Starting project setup...${RESET}"

# Step 1: Project/client name
read -p "Enter the project/client name: " client_name

# Step 2: Project description
read -p "Enter a short project description: " project_description

# Step 3: Choose dev server port
read -p "Preferred dev server port (default 5173): " dev_port
dev_port=${dev_port:-5173}

# Step 4: Is this a Progressive Web App?
read -p "Should this project be a Progressive Web App? (y/n): " is_pwa

# --- Update files with project data ---

# Update README.md
if [ -f README.md ]; then
  sed -i "s/PROJECT_NAME/$client_name/g" README.md
  sed -i "s/PROJECT_DESCRIPTION/$project_description/g" README.md
fi

# Update app.html
if [ -f src/app.html ]; then
  sed -i "s|<title>.*</title>|<title>$client_name</title>|g" src/app.html
  sed -i "s|<meta name=\"description\" content=\".*\">|<meta name=\"description\" content=\"$project_description\">|g" src/app.html

  if [[ "$is_pwa" =~ ^[Yy]$ ]]; then
    # Add manifest link if not already present
    if ! grep -q 'rel="manifest"' src/app.html; then
      sed -i '/<\/head>/i \  <link rel="manifest" href="/manifest.json">' src/app.html
      echo -e "${GREEN}✅ Added manifest link to app.html${RESET}"
    fi
  fi
fi

# Add manifest.json if needed
if [[ "$is_pwa" =~ ^[Yy]$ ]]; then
  cat <<EOF > public/manifest.json
{
  "name": "$client_name",
  "short_name": "$client_name",
  "start_url": "/",
  "display": "standalone",
  "background_color": "#ffffff",
  "theme_color": "#000000",
  "description": "$project_description",
  "icons": [
    {
      "src": "/icon-192.png",
      "sizes": "192x192",
      "type": "image/png"
    },
    {
      "src": "/icon-512.png",
      "sizes": "512x512",
      "type": "image/png"
    }
  ]
}
EOF
  echo -e "${GREEN}✅ Created public/manifest.json${RESET}"
fi

# Step 5: Create .env with dev port
if [ -f .env.example ]; then
  cp .env.example .env
  echo "VITE_PORT=$dev_port" >> .env
  echo -e "${GREEN}✅ .env created with dev port $dev_port${RESET}"
fi

# Step 6: MCP setup (optional)
echo ""
echo -e "${CYAN}🌐 Optional: Setup Figma MCP (Model Context Protocol)${RESET}"
read -p "Enter MCP API URL (or leave blank to skip): " mcp_url

if [ ! -z "$mcp_url" ]; then
  echo "MCP_API_URL=$mcp_url" >> .env
  echo -e "${GREEN}✅ MCP URL added to .env${RESET}"
fi

# Step 7: Install dependencies
if [ -f package.json ]; then
  echo -e "${BLUE}📦 Installing npm packages...${RESET}"
  npm install
fi

# Step 8: Initialize Git
echo -e "${BLUE}🔃 Initializing git...${RESET}"
rm -rf .git
git init
git add .
git commit -m "Initial commit for $client_name"

# Step 9: Final Output
echo ""
echo -e "${GREEN}${BOLD}✅ Project '$client_name' setup complete!${RESET}"
echo ""
echo -e "${BOLD}➡ Next steps:${RESET}"
echo -e "1. 🔍 Review ${CYAN}src/${RESET} and ${CYAN}components/${RESET} folders"
echo -e "2. 📝 Confirm ${CYAN}title${RESET} and ${CYAN}meta description${RESET} in ${CYAN}src/app.html${RESET}"
if [[ "$is_pwa" =~ ^[Yy]$ ]]; then
  echo -e "3. 🧱 Test PWA functionality (manifest is set up)"
fi
echo -e "4. 🔌 Check ${CYAN}.env${RESET} for VITE_PORT and optional MCP config"
echo -e "5. 🔁 ${YELLOW}If anything is missing, add notes to ${BOLD}UpdateTheSetup.md${RESET}${YELLOW}${RESET}"
echo ""
echo -e "${BOLD}🚀 Run: ${CYAN}npm run dev -- --port $dev_port${RESET}"
echo -e "${BOLD}🎉 Happy building!${RESET}"
