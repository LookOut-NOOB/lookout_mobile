# Look Out

🚀️  [Website](https://sites.google.com/view/lookout-fp/)

*A security, emergency , crime reporting and Management system*

This is the mobile app for the look out system.

### Secrets

Secret files are stored in `secrets` folder.

These are encrypted with git-crypt. Encrypted files are managed in `.gitattributes`

To decrypt the secret files in the repository after cloning

Acquire the encryption key(`git-crypt-key`) from publisher and paste it in the root folder of this repository.
Run (ensure git-crypt is installed, if not, [install](https://github.com/AGWA/git-crypt/blob/master/INSTALL.mdhttps:/) it):
`git-crypt unlock ./git-crypt-key`

All encrypted files will be decrypted and ready to use.

Command needs to be run only once. Files will then remain decrypted there after.

Files pushed to the repository are encrypted automatically there.

for refference about the encryption:

1. [https://github.com/AGWA/git-crypt#readme](https://github.com/AGWA/git-crypt#readmehttps:/)
2. [https://dev.to/heroku/how-to-manage-your-secrets-with-git-crypt-56ihLin](https://dev.to/heroku/how-to-manage-your-secrets-with-git-crypt-56ihLinhttps:/)
