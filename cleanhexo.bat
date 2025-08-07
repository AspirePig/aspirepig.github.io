set http_proxy=http://127.0.0.1:7890 & set https_proxy=http://127.0.0.1:7890
C:
cd C:\Users\admin\
rmdir /s /q "C:\Users\admin\aspirepig.github.io"
git clone git@github.com:AspirePig/aspirepig.github.io.git
cd aspirepig.github.io
git checkout --orphan new_branch
git add -A
git commit -m "Initial commit: Clean repository history"
git branch -D main
git branch -m main
git push -f origin main
git branch -a
pause