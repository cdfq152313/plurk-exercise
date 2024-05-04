import "@typespec/http";
import "@typespec/rest";
import "@typespec/openapi3";

using TypeSpec.Http;

@service({
  title: "Plurk - Module 1",
})
@useAuth(BearerAuth)
namespace Module1 {
  model SchedulerPlurk {
    id: string;
    content: string;
    user_id: string;
    posted: utcDateTime;
  }

  model UpsertSchedulerPlurkDto {
    @maxLength(360)
    content: string;

    posted: utcDateTime;
  }

  model Result {
    result: boolean;
  }

  @route("/scheduler/plurk")
  interface SchedulerPlurks {
    @doc("從最近到最遠排序，offset為分頁系統，沒給就從第一筆")
    @get
    list(
      @doc("請提供前端目前持有的最後一筆日期，會以此為基礎繼續向後搜尋")
      @query
      offset: utcDateTime,
    ): SchedulerPlurk[] | ForbiddenResponse;

    @doc("建立新預約時需提供發文日期及文章。不需要提供會員名稱，Server會從登入狀態直接拿此人的會員名稱。除了寫入資料庫，還會通知模組3。")
    @post
    create(
      @body createSchedulerPlurkDto: UpsertSchedulerPlurkDto,
    ): SchedulerPlurk | ForbiddenResponse;

    @doc("更改預約時需帶入發文id，其他與建立預約相同。不需要提供會員名稱，Server會從登入狀態直接拿此人的會員名稱。除了寫入資料庫，還會通知模組3。")
    @patch
    update(
      @path id: string,
      @body patchSchedulerPlurkDto: UpsertSchedulerPlurkDto | ForbiddenResponse,
    ): SchedulerPlurk;

    @delete
    @doc("刪除只需要id。除了寫入資料庫，還會通知模組3。")
    delete(@path id: string): Result | ForbiddenResponse;
  }
}
@service({
  title: "Plurk - Module 3",
})
namespace Module3 {
  model SchedulerPlurk {
    id: string;
    content: string;
    user_id: string;
    posted: utcDateTime;
  }

  model Result {
    result: boolean;
  }

  @route("/scheduler/plurk")
  interface SchedulerPlurks {
    @doc("建立排程。若時間 > n，則忽略")
    @post
    create(@body schedulerPlurk: SchedulerPlurk): Result;

    @doc("更新排程。若時間 < n，則更新排程時間。若時間 > n，則先查看原排程是否已有，若有則刪除。")
    @patch
    update(@body schedulerPlurk: SchedulerPlurk): Result;

    @delete
    @doc("刪除排程。當刪除預約的訊息到來，查看原排程是否已有，若有則刪除。")
    delete(@path id: string): Result;
  }
}
