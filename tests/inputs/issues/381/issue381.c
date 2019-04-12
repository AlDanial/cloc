/* implement the main bcon interface */

#define BCON_TRIGGER_PATH "/bivio/bcon_triggers/bcon_trigger/" 
#define BCON_TRIGGER_PATH_WITH_NAME "/bivio/bcon_triggers/bcon_trigger[@name=\"" 
#define BCON_TRIGGER_PATH_END_NAME "\"]/" 
#define BCON_TRIGGER_PATH_END_NAME_WITH_PRE_ASTRK "\"]/pre_triggers/*" 
#define BCON_TRIGGER_PATH_END_NAME_WITH_PRE_NO_ASTRK "\"]/pre_triggers/" 
#define BCON_TRIGGER_PATH_END_NAME_WITH_POST_ASTRK "\"]/post_triggers/*" 
#define BCON_TRIGGER_PATH_END_NAME_WITH_POST_NO_ASTRK "\"]/post_triggers/" 
#define BCON_TRIGGER_PATH_END_NAME_WITH_GET_ASTRK "\"]/get_triggers/*" 
#define BCON_TRIGGER_PATH_END_NAME_WITH_GET_NO_ASTRK "\"]/get_triggers/" 
#define BCON_TRIGGER_PATH_SET "set["


typedef struct ErrorConstant ErrorConstant;
struct ErrorConstant
{
        int		value;          /* value represented by the name */
        const char	*description;   /* human readable description */
};
