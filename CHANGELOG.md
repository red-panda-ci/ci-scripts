<a name="0.7.0"></a>
# 0.7.0 (2018-08-28)


### Build

* Add agent refertence in sonarqube step ([a1eddbdf0b95655646125b07004d200c77d3b308](https://github.com/red-panda-ci/ci-scripts/commit/a1eddbdf0b95655646125b07004d200c77d3b308))
* Add empty bin/test.sh script ([5841365d574313e662914e67c92aa504eca9d501](https://github.com/red-panda-ci/ci-scripts/commit/5841365d574313e662914e67c92aa504eca9d501))
* Put the right tag refefence to library ([a2d2f7dad477aab971db514662c404c3ad95aeaa](https://github.com/red-panda-ci/ci-scripts/commit/a2d2f7dad477aab971db514662c404c3ad95aeaa))
* Update to jpl v2.6.2 ([409343d1d41010cd0dbfcce9a0a999460edaf4a9](https://github.com/red-panda-ci/ci-scripts/commit/409343d1d41010cd0dbfcce9a0a999460edaf4a9))

### New

* Add docker wraper to the install process ([a3265e9981192d3493006d706d1bd00f7ec5841f](https://github.com/red-panda-ci/ci-scripts/commit/a3265e9981192d3493006d706d1bd00f7ec5841f))

### Update

* Arrange signApk.sh script ([fc70186b065fd0e60083a37600a3b51f261b17b8](https://github.com/red-panda-ci/ci-scripts/commit/fc70186b065fd0e60083a37600a3b51f261b17b8))
* Change bin/signApk.sh docker image behaviour ([3095a867e647fbf7102a722000a7aa0cb81060e6](https://github.com/red-panda-ci/ci-scripts/commit/3095a867e647fbf7102a722000a7aa0cb81060e6))



<a name="0.6.0"></a>
# 0.6.0 (2017-12-07)


### Breaking

* Move from oracle to openjdk jdk, some changes in the build process ([4bc7b850d5ad0c7a9174d039220a2d5d54d35917](https://github.com/red-panda-ci/ci-scripts/commit/4bc7b850d5ad0c7a9174d039220a2d5d54d35917))

### Build

* Add Jenkinsfile ([634fa2cb344afccc0b4d63393eb94c38a3418a0a](https://github.com/red-panda-ci/ci-scripts/commit/634fa2cb344afccc0b4d63393eb94c38a3418a0a))
* Build & push android emulator docker image ([c4f3b10d42e06258d5e8528c87e3be2d7d94e240](https://github.com/red-panda-ci/ci-scripts/commit/c4f3b10d42e06258d5e8528c87e3be2d7d94e240))
* Update CHANGELOG.md to v0.6.0 with Red Panda JPL ([e83fdc2570046569d405de3b1406d5870386d45a](https://github.com/red-panda-ci/ci-scripts/commit/e83fdc2570046569d405de3b1406d5870386d45a))

### Fix

* Use correct argument for version name ([bfd2aad78fd70631adc1096e3bf54f072ed83605](https://github.com/red-panda-ci/ci-scripts/commit/bfd2aad78fd70631adc1096e3bf54f072ed83605))
* Use last zipalign in jplSigning ([b42018166d555b16a51cde56f579a1b05c19ff00](https://github.com/red-panda-ci/ci-scripts/commit/b42018166d555b16a51cde56f579a1b05c19ff00))
* Use quotes in dirname commands ([08149e50bac0aea35a6009b7d287626585981749](https://github.com/red-panda-ci/ci-scripts/commit/08149e50bac0aea35a6009b7d287626585981749))
* use the right debug.keystore file ([240e0123e7ed326c00cf0df79f20eb355bf1eadc](https://github.com/red-panda-ci/ci-scripts/commit/240e0123e7ed326c00cf0df79f20eb355bf1eadc))

### New

* Add android debug keystores for docker images ([8562a8959f123c107b3f5b88a482d4da3571501e](https://github.com/red-panda-ci/ci-scripts/commit/8562a8959f123c107b3f5b88a482d4da3571501e))
* Add git promote script bin/git-promote.sh ([5806615beef5ec894938258ed26506f56330d623](https://github.com/red-panda-ci/ci-scripts/commit/5806615beef5ec894938258ed26506f56330d623))
* Include bin/signApk.sh android apk artifacts signer ([022c1d193438dca5c3c0d27562c52afdbd6c89b5](https://github.com/red-panda-ci/ci-scripts/commit/022c1d193438dca5c3c0d27562c52afdbd6c89b5))
* Include bin/uploadYatt.sh script ([8f7cf101d386dcf79062131a4f3c23424bb704b7](https://github.com/red-panda-ci/ci-scripts/commit/8f7cf101d386dcf79062131a4f3c23424bb704b7))

### Update

* Remove unused projectName parameter ([ba7b1ee880de80ed7e3382ca5db131715dbc3e8d](https://github.com/red-panda-ci/ci-scripts/commit/ba7b1ee880de80ed7e3382ca5db131715dbc3e8d))



<a name="0.4.2"></a>
## 0.4.2 (2017-06-26)




<a name="0.4.1"></a>
## 0.4.1 (2017-06-26)




<a name="0.4.0"></a>
# 0.4.0 (2017-06-25)




<a name="0.3.8"></a>
## 0.3.8 (2017-06-16)




<a name="0.3.7"></a>
## 0.3.7 (2017-06-06)




<a name="0.3.6"></a>
## 0.3.6 (2017-05-30)




<a name="0.3.4"></a>
## 0.3.4 (2017-04-10)




<a name="0.3.3"></a>
## 0.3.3 (2017-03-27)




<a name="0.3.1"></a>
## 0.3.1 (2017-03-27)




<a name="0.2.0"></a>
# 0.2.0 (2017-03-16)


### Bugfix

* double docker image creation ([74587048bc312c7fa24d5ca2ce05b0383fb75cfa](https://github.com/red-panda-ci/ci-scripts/commit/74587048bc312c7fa24d5ca2ce05b0383fb75cfa))

### Fix

* using script variable as command ([2cabd365c40e4499b80d3d59baea6c0f2b13e448](https://github.com/red-panda-ci/ci-scripts/commit/2cabd365c40e4499b80d3d59baea6c0f2b13e448))



