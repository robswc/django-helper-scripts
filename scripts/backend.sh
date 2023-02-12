#!/bin/bash
version="1.0.0"
name="backend.sh"

# Sets up an existing Django project with common backend add-ons

python_packages="djangorestframework django-cors-headers drf-yasg whitenoise"

# check if python is installed
if ! command -v python &>/dev/null; then
  echo "Python could not be found"
  exit
fi

# Prompt the user for the name of the project
read -p "Enter the name of the Django project (hit enter for current directory): " project_name

# check if project name is empty
if [ -z "$project_name" ]; then
  # set project name current folder name if empty
  project_name=$(basename "$PWD")
fi

# Install packages using pip
pip install $python_packages

# check to see if file exists
if [ -f "${project_name}"/settings.py ]; then
  echo "Settings File exists"
else
  # prompt user to create a new project
  read -p -r "File does not exist. Would you like to create a new project? (y/n): " create_project
  if [ "$create_project" == "y" ]; then
    # create a new project
    django-admin startproject "${project_name}"
  else
    # exit the script
    exit 1
  fi
fi

# modify Django settings file to add necessary additions
echo "Modifying Django settings file..."
echo -e "\n\n# Added by $name $version (@robswc)" >>"${project_name}"/settings.py
echo "INSTALLED_APPS += ['drf_yasg', 'corsheaders']" >>"${project_name}"/settings.py
echo "MIDDLEWARE += ['corsheaders.middleware.CorsMiddleware', 'django.middleware.common.CommonMiddleware']" >>"${project_name}"/settings.py
echo "MIDDLEWARE += ['whitenoise.middleware.WhiteNoiseMiddleware']" >>"${project_name}"/settings.py
echo 'STATIC_ROOT = BASE_DIR / "staticfiles"' >>"${project_name}"/settings.py
echo "CORS_ALLOWED_ORIGINS = ['http://localhost:8000', 'http://127.0.0.1:8000']" >>"${project_name}"/settings.py
echo "Finished..."
