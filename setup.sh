#!/bin/bash

# Colors
GREEN='\033[0;32m'
BLUE='\033[1;34m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
BOLD='\033[1m'
RESET='\033[0m'

echo -e "${BLUE}${BOLD}🛠 Starting project setup...${RESET}"

# Step 1: Ask for project/client name
read -p "Enter the project/client name: " client_name

# Step 2: Rename in README.md and other metadata
if [ -f README.md ]; then
  sed -i "s/PROJECT_NAME/$client_name/g" README.md
fi

# Step 3: Update title and description in app.html
if [ -f src/app.html ]; then
  sed -i "s|<title>.*</title>|<title>$client_name</title>|g" src/app.html
  sed -i "s|<meta name=\"description\" content=\".*\">|<meta name=\"description\" content=\"$client_name site description\">|g" src/app.html
fi

# Step 4: Copy .env file
if [ -f .env.example ]; then
  cp .env.example .env
  echo -e "${GREEN}✅ .env file created${RESET}"
fi

# Step 5: Install dependencies
if [ -f package.json ]; then
  echo -e "${BLUE}📦 Installing npm packages...${RESET}"
  npm install
fi

# Step 6: Ask for optional Figma MCP setup
echo ""
echo -e "${CYAN}🌐 Optional: Setup Figma MCP (Model Context Protocol)${RESET}"
read -p "Enter MCP API URL (or leave blank to skip): " mcp_url

if [ ! -z "$mcp_url" ]; then
  if [ -f .env ]; then
    sed -i "s|MCP_API_URL=.*|MCP_API_URL=$mcp_url|" .env
    echo -e "${GREEN}✅ MCP API URL added to .env${RESET}"
  fi
fi

# Step 7: Git setup
echo -e "${BLUE}🔃 Initializing git...${RESET}"
rm -rf .git
git init
git add .
git commit -m "Initial commit for $client_name"

# Optional: Self-delete the setup file
# Uncomment if you want the script to remove itself after running
# rm -- "$0"

# Step 8: Completion message
echo ""
echo -e "${GREEN}${BOLD}✅ Project '$client_name' setup complete!${RESET}"
echo ""
echo -e "${BOLD}➡ Next steps:${RESET}"
echo -e "1. 🔍 Review ${CYAN}src/${RESET} and ${CYAN}components/${RESET} folders — remove unused components and adjust the structure"
echo -e "2. 📝 Update ${CYAN}src/app.html${RESET} title and meta description (already filled with '$client_name')"
echo -e "3. 📦 Edit ${CYAN}package.json${RESET} name, author, or scripts if needed"
echo -e "4. 🔌 Check Figma MCP setup in ${CYAN}.env${RESET} if used"
echo -e "5. 🛠 ${YELLOW}If something’s missing, create or update ${BOLD}UpdateTheSetup.md${RESET}${YELLOW} to document improvements${RESET}"
echo ""
echo -e "${BOLD}🚀 Run: ${CYAN}npm run dev${RESET} to start the development server"
echo -e "${BOLD}🎉 Happy building!${RESET}"
