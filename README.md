# ExpertSystem
Expert system identifying person by using basic knowledge, written in Logtalk. The *expert_system.lgt* writes all facts into *db.lgt* as describes of objects (which names are subnames of specific person).
User is able to add new people (but one person for one subname). Facts are in Polish so I recommend translate it. Anyway, the code is written in English.

To compile & run, write in terminal
```
$ swilgt -g 'logtalk_load(expert_system)' -g 'start.'
```

Logtalk: https://github.com/LogtalkDotOrg/logtalk3


