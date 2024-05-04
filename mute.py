from typing import Any, List, Set, Dict, Coroutine
import asyncio


async def execute_sql(shard_id: int, query: str) -> Coroutine[None, None, Any | List[Any]]:
   """假設操作 DB 可以用 asyncio 來做"""

async def update_plurk_post_unread(shard_id: int, plurk_id: int, user_ids: List[int]):
   """batch update 同一個shard 裡面的 user"""

async def update_unreads(plurk_post: PlurkPostORMObject):
    # 取得閱讀這則噗的使用者
    related_users: List[UserORMObject] = get_reading_users(plurk_post)

    # 將 user 按照 shard 進行分組
    shard_dict: Dict[int, List[UserORMObject]] = {}
    for user in related_users:
        shard_dict.setdefault(user.shard_id, []).append(user)

    # 不同 shard 為不同 task
    tasks = [
        asyncio.create_task(update_unreads_in_shard(shard_id, plurk_post, related_users))
        for shard_id, related_users in shard_dict.items()
    ]

    await asyncio.wait(tasks)

async def update_unreads_in_shard(shard_id: int, plurk_post: PlurkPostORMObject, related_users: List[UserORMObject]):
    # 直接撈該噗的所有消音用戶，取得消音List後將其轉為Set
    muted_user_ids: Set[int] = set(await execute_sql(
        shard_id,
        f"SELECT `user_id` FROM `mutes` WHERE `plurk_id`=f{plurk_post.id};",
    ))
    # 拿掉被消音對象
    updating_users = [
        user for user in related_users if user.id not in muted_user_ids
    ] 

    # 標記為 unread
    await update_plurk_post_unread(shard_id, plurk_post.id, updating_users)