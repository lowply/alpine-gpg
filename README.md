# alpine-gpg

This is a simple Docker image with [gnupg](https://gnupg.org/) that allows you to test encryption / decryption without polluting your local environment.

## A real world example

### Scenario

- Bob wants to share a secret file with Alice
- Alice to share her gpg public key with Bob
- Bob to encrypt the secret file using Alice's public key and send her the file
- Alice to decrypt the file using her private key
- I am Bob (local) and Alice's environment in the container

```
[Bob] <--- (pubkey) ---- [Alice]
[Bob] ---- ( file ) ---> [Alice]
```

### Inside the container (Alice)

Build and run the container by running `make build && make run`. Inside the container, generate a key pair:

- No passphrase
- No expiration
- ed25519 algorithm

```
gpg --batch --passphrase '' --quick-gen-key "Alice <alice@example.com>" future-default - 0
```

_Make sure you set the passphrase and the expiration date properly for production use. This is only for the testing._

Check the key by listing private keys in the short (8 character) format.

```
gpg -K --keyid-format SHORT
```

Export the public key in the ASCII format (-a).

```
gpg -a --export alice@example.com > data/alice@example.com.pub
```

Now, share the public key with Bob. Don't do `gpg --send-keys` because once it's published, you can't delete it.

### Local (Bob)

On macOS, gpg can be installed via homebrew.

```
brew install gpg
```

Open a new terminal window. Import the public key sent by Alice.

```
gpg --import data/alice@example.com.pub
gpg -k
```

Sign a file using the public key.

```
echo "Hello, this is a secret" > data/file.txt
gpg -e -r alice@example.com data/file.txt
```

Finally, send the encrypted `file.txt.gpg` file to Alice. Since this is a binary, you don't have to gzip it before sending it.

### In the container again (Alice)

Alice received the file from Bob. Now let's decrypt the file using the private key.

```
gpg -d data/file.txt.gpg
```

### Cleanup

If you're ok to finish the test, exit the docker container and delete the pubkey from your local environment.

```
gpg --delete-key alice@example.com
gpg -k
```

## Git and GitHub

### Add your key to your .gitconfig

```
git config --global gpg.program gpg
git config --global user.signingkey your-email@example.com
```

### Commit and Tag signing

I usually don't sign my commits but tags. In `~/.gitconfig`:

```
git config --global commit.gpgsign false
git config --global tag.gpgsign true
```

### Add the public key to your GitHub account

```
gpg -a --export your-email@example.com | pbcopy
```

## Other basic commands

### For production use

The key should have the passphrase and expiration date for production use.

```
gpg --quick-gen-key "Your Name <your-email@example.com>" future-default - 1y
```

### Export the secret key for backup

```
gpg --export-secret-key -a your-email@example.com
```

### Delete the secret key

```
gpg --delete-secret-keys your-email@example.com
```

### Generate a revocation certificate

```
gpg -o your-email@example.com.revoke --gen-revoke your-email@example.com
```

Move it to the safe location and remove it

_TODO: Write the key revoking procedure_

### Search public keys on the internet

```
gpg --search-keys your-email@example.com
```
