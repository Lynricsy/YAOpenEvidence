import { useMutation } from '@tanstack/react-query'
import { toast } from 'sonner'
import { deleteAnswer } from '@/api/queries'
import {
  AlertDialog,
  AlertDialogContent,
  AlertDialogHeader,
  AlertDialogTitle,
  AlertDialogDescription,
  AlertDialogFooter,
  AlertDialogCancel,
} from '@/components/ui/alert-dialog'
import { Button } from '@/components/ui/button'
export function DeleteAnswerDialog({
  id,
  onClose,
  onDeleted,
}: {
  id: string | null
  onClose: () => void
  onDeleted?: () => void
}) {
  const mutation = useMutation({
    mutationFn: deleteAnswer,
    onSuccess: () => {
      toast.success('答案已删除')
      onClose()
      onDeleted?.()
    },
  })
  return (
    <AlertDialog
      open={!!id}
      onOpenChange={(open) => {
        if (!open && !mutation.isPending) onClose()
      }}
    >
      <AlertDialogContent>
        <AlertDialogHeader>
          <AlertDialogTitle>删除这份答案？</AlertDialogTitle>
          <AlertDialogDescription>
            问答结果与本次阅读材料将被删除，共享文献库不受影响。此操作不可撤销。
          </AlertDialogDescription>
        </AlertDialogHeader>
        <AlertDialogFooter>
          <AlertDialogCancel disabled={mutation.isPending}>
            保留
          </AlertDialogCancel>
          <Button
            variant="destructive"
            disabled={mutation.isPending}
            onClick={() => {
              if (id) mutation.mutate(id)
            }}
          >
            {mutation.isPending ? '删除中…' : '删除'}
          </Button>
        </AlertDialogFooter>
      </AlertDialogContent>
    </AlertDialog>
  )
}
