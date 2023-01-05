#!/usr/bin/bash
#sandylaw 2020-09-14
if [ -f rssbot-v1.4.4-linux.zip ]; then
    :
else
    wget https://github.com/iovxw/rssbot/releases/download/v1.4.4/rssbot-v1.4.4-linux.zip
fi
rm -f rssbot
unzip rssbot-v1.4.4-linux.zip 
cat <<EOF | tee DATAFILE
[{"link":"http://rsshub.app/github/issue/headllines/hackernews-daily","title":"headllines/hackernews-daily Issues","error_count":0,"subscribers":[396565070],"hash_list":[6432068443644649451,4810063853953030561,5207584846166622002,11085657736484897213,7220889858021753233,15953432677504808661,284767937280428620,18335970068532906938,7433912342200560972,15511092597601396380,13513123299012373342,7594993386380891843,7968832049838218054,8671028406809239429,4427684627561627170,13909641758727988385,3282356475949902108,8386770135701879252,18190155542712165429,17480052756836755930,5991544795953090723,13118119901704345604,6672856519890905997,15630355473872963656,16212083937425069169,16083840282211299818,10797438012493216598,10143620526958533314,11587789908896751464,8623936922448589996]},{"link":"https://www.williamlong.info/rss.xml","title":"月光博客","error_count":0,"subscribers":[396565070],"hash_list":[18282506100910797965,15726655261887771269,8255718454615036591,4197136488798948472,14452004244507767307,17932436804307754003,3943358931016297926,9048673387042920574,8499492820821914006,4979718436987863402]},{"link":"http://rsshub.app/blogs/wangyin","title":"王垠的博客 - 当然我在扯淡","error_count":0,"subscribers":[396565070],"hash_list":[9405292570037190839,10812078690144783637,11322906066136977728,14565669355529370966,6935767491089334531,5759268301940830838,11781543652685516271,18038347230130544350,15913629026128093917,5342333105004690497,2527172207039090236,14953421641037588150,9581160900252967418,7309169413645085724,5209863923657802111,12403407831446944895,5714957405140786575,15592246727129239434,14206818821633853366,7420758317524403568,6574997139529572561,3868308951685368589,5935315824013362784,7175683242983128749,15894271955521340746,7221094351289980897,5863077445673704891,6111491143768252612,11162845802928380903,12522705562295814861,1583124627625201511,11697644888234525094,16750933187894561390,5779727886435846192,16646240865612477973,925709038415093610,1908396941692924982,2266670197782421182,4638976547371259660,16697301802975617436,16031978897417753672,15140590306434591444,2459738971229961580,16253187267385945427,9627479900719188170,8898291474631633879,14297769374372548066,6605857743318069207,12373408480794668152,13939154856026614362,16336866594298501030,17116883920960701371,13526197300292772208,4512871884303685754,16920842680817918425,10837701658270681113,8809041876318556720,17585973603065553277,13634855102027929261,11174946533678394144,2840692013566401776,1157689338936472086,11427783356584573736,18052623993813190150,4377634499588782254,12757123199245438604,8828257263434316022,7532607414115288602,7361527338051935101,13772576748873133967,17914575205252345917,17501836504463479370,6488124932676507979,7255313614219925683,870535846867113005,13766048555130687254,8586379351882432204,13881019809635058045,16521298129287742720,2192618445339395355,1841335925714012126,18308658250980577920,15418545924206962561,8261395973999278521,7720775539376104869,6555932501548664479,6613465120573143899,2052302358027230845,18141007109324607254,1326429678699083833,14147933558969375365,8006683138873559271,8841818773260977972,12653426061511656072,5138577873522786089,8641743977824453792,11751862210110248525,6712527883295903972,12408186814466196452,7638237962977726012,4731237446463300923,3904214912471560002,15407652652829185875,11674851194926988197,5319006777378586843,313614391318747673,11485698655336058514,5441356987906511707,7028095776621202870,11821161937755224537,14668230840060153578,13072482421695062244,8618513176154061936,5001558472055866375,15919061152240552355,1469166330774458906,15277629129577393184,15413225968397718204,1901874120957328784,781969995860499444,9575450041002819487,269756392082781548,13103291545679875087,1258499504966384829,8791069189715067620,11303452320838685760,6130592795859163668,15191578433255937100,670746722578525587,18265499838000388078,8744413295837031144,7338390495006324231,13231484700367024726,5450522857977087786,4158095590200250790,14559492648097478599,3566179333331862381,15113421579230704153,15343320025590388056,3806495016838883640,13048174600509989731,18074902100405272093,12703261119474625028,2462187846657937129,10169188994892022348,14703459069575525089,4905315675254964848,12174668784382203630,2843356793277046303,13541955697654196711,17307011259224704576,13571175973607148827]},{"link":"https://sspai.com/feed","title":"少数派","error_count":0,"subscribers":[396565070],"hash_list":[16339849140398947497,84839264149661500,7270792369071102146,2303997369151772542,2287781718027931691,16702054201956835768,10542327158081853516,13695770074801782405,990524226397516193,14770237781616151782]},{"link":"http://feeds.feedburner.com/ruanyifeng","title":"阮一峰的网络日志","error_count":0,"subscribers":[396565070],"hash_list":[11575254185300943222,16425411498674283109,17294870054049317799,12560686170087956259,3422910630701636883,17719631612690640205]}]
EOF
nohup ./rssbot DATAFILE 1297390951:AAEdAx9pMhM7J1yMrGryDVk7zWMkwkAfyqs > /dev/null 2>&1 &
