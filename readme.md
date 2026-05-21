# For those who don't know how to use GitHub:

## Step 1: Create a User Account in Github

Go to GitHub.com and click the **Sign-Up** button;
Fill all the credentials, verify the account and edit your profile (optional)

## Step 2.1: Install Git

Install [Git](https://git-scm.com/install/) if you haven't already and do the installation. Git will be the terminal used to interact from your Local Machine to GitHub. 

## Step 2.2: Download Visual Studio Code & The Folder Project

If you haven't already, download [Visual Studio Code](https://code.visualstudio.com/Download) and do the installation process.

Make sure that you know where to place the files in your computer. I personally recommend cloning the project in your **C://Users//{User}//{folder_name}**, folder_name Folder can be named on whatever you want.

Sign-in to GitHub in Visual Studo Code by clicking the Accounts Button, usually in the bottom-left

## Step 3.1: Fork the Repository of the Project in Visual Studio Code

Keep your Visual Studio Code open and go to the GitHub Repository.

Press the Fork Button beside the Watch and Star buttons.

Check if the owner is you and change the Repository Name on whatever you want- do not uncheck the checkbox as it copies the **"Main Branch"**. Click the **"Click Fork"** button if you're finished, it will redirect you to your forked repository.

Click the Big Green Button named **"<> Code"**, copy the HTTPS link, and go back to the created folder where you will be storing the files. Make sure that you are inside of the Folder (e.g., **"C:/Users/John Doe/Projects_Folder/"**).

Open your bash terminal in the very top of the screen by clicking the 3 dots (**...**) button besides the run button, or simply use the **"Ctrl + Shift + ~"** shortcut in your keyboard. Check if you're in the right directory by checking in the terminal, usually highlighted with the color yellow.

Input the following:
```bash
git clone
```
And copy paste the HTTPS link

### Congrats! You successfully added a repository in your local machine

## Step 3.2: Branches

Branches are a way to make sure that you don't tamper with the main branch and by creating your own branch, you can safely make changes without worrying about anything in the main branch.

To create your own branch, do the following:

```bash
git checkout -b branch-name
```

To check all the branches, do:

```bash
git branch
```

To switch branches, do:
```bash
git checkout branch-name
```

Rule of Thumb: Don't change anything on the main branch unless the Owner of the Repository said so.

## Step 4: Applying Username and Email in VSCode for Git Settings

You can't just code after doing the steps above, you need to configure your Username and Email in VSCode.

To set them, open your bash terminal if you haven't already and type:
```bash
git config --global user.name "Your Name"
git config --global user.email "youremail@example.com"
```

Git uses this to identify who made each commit.

To check your Username and Email:
```bash
git config --global user.name
git config --global user.email
```

Or simply
```bash
git config user.name
git config user.email
```

Since they are already global or in every repository.

## Questions

If you have any question, please refer to John Vincent Castro or Xander Ney Lopez.