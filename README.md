# DB_System_Architecture_P1
Repository for the development of the first project of the course DATABASE SYSTEM ARCHITECTURE (INFO-H-417)  from the program BDMA. Fall 2022.

This project consists of studying the execution plan for 4 different queries on a given dataset and optimize them as much as possible.

Group members:

- [Aliakberova, Liliia](https://github.com/Liliia-Aliakberova)
- [Gepalova, Arina](https://github.com/omymble)
- [Lorencio Abril, Jose Antonio](https://github.com/Lorenc1o)
- [Mayorga Llano, Mariana](https://github.com/marianamllano)

Professor: Sakr, Mahmoud

Some useful instructions:

Executing the restore.sql file to provide the data to the database could result in permissions conflicts, as the command COPY FROM is executed by the server, which may not have access to user files.

Possible solutions are:

1) Changing *COPY FROM* to *\copy from* is probably the most correct one, as the command \copy gets executed by the client, thus respecting a possible permissions design.

2) In principle, copying the used files to /tmp shoul work as well, although some of us have experienced problems trying to do this.

3) Changing the owner of the folder where the data files are located to postgres:postgres should work as well.
