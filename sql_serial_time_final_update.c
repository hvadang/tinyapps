#include <stdio.h>
#include <string.h>
//#include <stdint.h>
#include <my_global.h>
#include <mysql.h>
#include <stdlib.h>
#include <time.h>
struct sensordata
{
	int nodeID;
	float temp;
	float humi;
	float light;
};
void finish_with_error(MYSQL *con)
{
  fprintf(stderr, "%s\n", mysql_error(con));
  mysql_close(con);
  exit(1);        
}
//split value in buffer into seperated value and store them in data struct
struct sensordata *convert(char *buffer)
{
	struct sensordata *data = malloc(sizeof(struct sensordata));
	int len = strlen(buffer);
	int i=0, j=0;
	char *group = malloc(10*sizeof(char));
	char pos[5];
	for (i=0; i<len; i++)
	{
		if (buffer[i]==' ')
		{
			pos[j]=i;
			j++;
		}		
	}
	//save nodeID value
	for (i=0; i<pos[0]; i++)
	{
		group[i]=buffer[i];
	}
	group[i]='\0';
	data->nodeID = atoi(group);
	free(group);
	j=0;
	//save temp value
	char *group2 = malloc(10*sizeof(char));
	for (i=pos[0]+1; i<pos[1]; i++)
	{
		group2[j]=buffer[i];
		j++;
	}
	group2[i]='\0';
	data->temp = atof(group2);
	free(group2);
	j=0;
	//save humi value
	char *group3 = malloc(10*sizeof(char));
	for (i=pos[1]+1; i<pos[2]; i++)
	{
		group3[j]=buffer[i];
		j++;
	}
	group3[i]='\0';
	data->humi = atof(group3);
	free(group3);
	j=0;
	//save light value
	char *group4 = malloc(10*sizeof(char));
	for (i=pos[2]+1; i<pos[3]; i++)
	{
		group4[j]=buffer[i];
		j++;
	}
	group4[i]='\0';
	data->light = atof(group4);
	free(group4);
	return data;
}
int main(int argc, char *argv[])
{
	//printf mySQL version
	printf ("MySQL client version: %s\n", mysql_get_client_info());
	
	//connect to mySQL server
	MYSQL *con = mysql_init(NULL);
	if (con==NULL)
	{
		fprintf (stderr, "%s\n", mysql_error(con));
		exit(1);
	}	
	
	if (mysql_real_connect(con, "localhost", "root", "", NULL, 0, NULL, 0) == NULL)
	{
		fprintf(stderr, "%s\n", mysql_error(con));
		mysql_close(con);
		exit(1);	
	}
	//uncomment if you have not created database
	/*if (mysql_query(con, "CREATE DATABASE sensordata"))
	{
		fprintf(stderr, "%s\n", mysql_error(con));
		mysql_close(con);
		exit(1);
	}
	*/
	if (mysql_query(con, "USE smartgardens_db"))
	{
		printf("use db\n");
		finish_with_error(con);
	}
	/*
	if (mysql_query(con, "DROP TABLE IF EXISTS Data"))
	{
      		finish_with_error(con);
  	}
  	
	if (mysql_query(con, "CREATE TABLE Data(NodeID INT, Temperature FLOAT, Light FLOAT, Humidity FLOAT, Time TEXT)")) 
	{      
      		finish_with_error(con);
  	}*/
	char str[50];
	int fd = open("/dev/ttyUSB1", O_RDONLY | O_NOCTTY);
   	if (fd == -1)
  	{
        /* Could not open the port. */
      	 perror("open_port: Unable to open /dev/ttyUSB - ");
    	}
	char buffer[20];
	char s[64];
	while(1)
	{
	    ssize_t length = read(fd, &buffer, sizeof(buffer));
	    if (length == -1)
	    {
		printf("Error reading from serial port\n");
		break;
	    }
	    else if (length == 0)
	    {
		printf("No more data\n");
		break;
	    }
	    else
	    {
		printf("data: \n");
		buffer[length]='\0';
		strcat(str, buffer);
		if (buffer[length-1] =='\n')
		{
			printf("%s", str);
			char *sql_insert = malloc(200*sizeof(char));
			struct sensordata *data = convert(str);
			time_t t = time(NULL);
    			struct tm *tm = localtime(&t);
    			strftime(s, sizeof(s), "%c", tm);
			//printf("abc");
			switch(data->nodeID){
			case 2:
				sprintf(sql_insert, "UPDATE node SET temperature=%0.2f,light=%0.2f,humidity=%0.2f,time='%s' WHERE id=2", data->temp, data->light, data->humi, s); break;
			case 3:
				sprintf(sql_insert, "UPDATE node SET temperature=%0.2f,light=%0.2f,humidity=%0.2f,time='%s' WHERE id=3", data->temp, data->light, data->humi, s); break;
			case 14:
				sprintf(sql_insert, "UPDATE node SET temperature=%0.2f,light=%0.2f,humidity=%0.2f,time='%s' WHERE id=14",data->temp, data->light, data->humi, s); break;
			case 15:
				sprintf(sql_insert, "UPDATE node SET temperature=%0.2f,light=%0.2f,humidity=%0.2f,time='%s' WHERE id=15",data->temp, data->light, data->humi, s); break;
			case 16:
				sprintf(sql_insert, "UPDATE node SET temperature=%0.2f,light=%0.2f,humidity=%0.2f,time='%s' WHERE id=16",data->temp, data->light, data->humi, s); break;
			default:
				sprintf(sql_insert," ");break;
			}
			//sprintf(sql_insert, "INSERT Into node VALUES(%d, %0.2f, %0.2f, %0.2f, '%s')",data->nodeID, data->temp, data->light, data->humi, s);
			printf("SQL_insert: %s\n",sql_insert);
			if(strlen(sql_insert)>1){
			if (mysql_query(con, sql_insert))
			{
				finish_with_error(con);
			}
			}
			free(sql_insert);
			free(data);
			strcpy(str,"");
			
		}
			
	    }
	}
	//free(str);
	mysql_close(con);
	exit(0);
}

