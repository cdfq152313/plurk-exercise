import "@typespec/http";
import "@typespec/rest";
import "@typespec/openapi3";

using TypeSpec.Http;

model SchedulerPlurk {
  id: string;
  content: string;
  user_id: string;
  posted: utcDateTime;
}

@route("/scheduler/plurk")
interface SchedulerPlurks {
  list(): SchedulerPlurk[];
}
